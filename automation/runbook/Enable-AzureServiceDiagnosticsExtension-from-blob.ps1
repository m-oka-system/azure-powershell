# Parameter
Param( 
	[Parameter (Mandatory= $true)] 
	[string]$CloudServiceName,

	[Parameter (Mandatory = $true)] 
	[string]$StorageAccountName,
	
	[Parameter (Mandatory = $true)] 
	[string]$ContainerName
)

$ErrorActionPreference = 'stop'

# Login
$ConnectionAssetName = "AzureClassicRunAsConnection"
$connection = Get-AutomationConnection -Name $connectionAssetName        

Write-Verbose "Get connection asset: $ConnectionAssetName" -Verbose
$Conn = Get-AutomationConnection -Name $ConnectionAssetName
if ($Conn -eq $null)
{
    throw "Could not retrieve connection asset: $ConnectionAssetName. Assure that this asset exists in the Automation account."
}

$CertificateAssetName = $Conn.CertificateAssetName
Write-Verbose "Getting the certificate: $CertificateAssetName" -Verbose
$AzureCert = Get-AutomationCertificate -Name $CertificateAssetName
if ($AzureCert -eq $null)
{
    throw "Could not retrieve certificate asset: $CertificateAssetName. Assure that this asset exists in the Automation account."
}

Write-Verbose "Authenticating to Azure with certificate." -Verbose
Set-AzureSubscription -SubscriptionName $Conn.SubscriptionName -SubscriptionId $Conn.SubscriptionID -Certificate $AzureCert 
Select-AzureSubscription -SubscriptionId $Conn.SubscriptionID

# Download configfile from blob
$StorageKey = (Get-AzureStorageKey -StorageAccountName $StorageAccountName).Primary
$Context = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageKey
$TemporaryFolder = $env:TEMP

Write-Verbose "Searching diagnostics configuration file from storage account '$StorageAccountName' and container '$ContainerName'" -Verbose

$Blobs = Get-AzureStorageBlob -Container $ContainerName -Context $Context
$configFiles = $Blobs | Where-Object {$_.Name -Match ".PubConfig.xml"}
Write-Verbose "Writing diagnostics configuration file to temporary location" -Verbose
$configFiles | Get-AzureStorageBlobContent -Destination $TemporaryFolder -Context $Context -Force >$null 2>&1

# Enable Azure Diagnostics extension on each role
Write-Output "Enables Azure Diagnostics extension on each role" -Verbose
$roles = (Get-AzureRole -ServiceName $CloudServiceName).RoleName
foreach ($role in $roles)
{
    $config = "PaaSDiagnostics.$($role).PubConfig.xml"
    $config = Join-Path $TemporaryFolder $config

    if($config -eq $null) {
        throw 'No diagnostics configuration file found'
    }

    Set-AzureServiceDiagnosticsExtension -ServiceName $CloudServiceName -StorageContext $Context -DiagnosticsConfigurationPath $config
    Remove-Item $config -Force
    Write-Output "$($role) extension has been activated"
}

Write-Verbose "All done!" -Verbose