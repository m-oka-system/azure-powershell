# Parameter
Param( 
	[Parameter (Mandatory= $true)] 
	[string]$CloudServiceName,
	
	[Parameter (Mandatory = $true)] 
	[ValidateSet("staging","production")]
	[string]$CloudServiceSlot,
	
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

# Set cspkg,cscfg path
$StorageKey = (Get-AzureStorageKey -StorageAccountName $StorageAccountName).Primary
$Context = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageKey
$TemporaryFolder = $env:TEMP

Write-Verbose "Searching Azure Cloud Package and configuration file from storage account '$StorageAccountName' and container '$ContainerName'" -Verbose

$Blobs = Get-AzureStorageBlob -Container $ContainerName -Context $Context | Sort-Object 'LastModified'

$LatestAzurePackage = $Blobs | Where-Object {$_.Name -Match ".cspkg"} | Select-Object -Last 1
$LatestAzureConfigurationFile = $Blobs | Where-Object {$_.Name -Match ".cscfg"} | Select-Object -Last 1

if($LatestAzurePackage -eq $null) {
    throw 'No Azure package (cspkg) found'
}

if($LatestAzureConfigurationFile -eq $null) {
    throw 'No Azure configuration file (cscfg) found'
}

$AzurePackageUrl = $LatestAzurePackage.ICloudBlob.uri.AbsoluteUri
$AzureConfigurationFile = Join-Path $TemporaryFolder $LatestAzureConfigurationFile.Name
Write-Verbose "Writing Azure configuration file to temporary location $AzureConfigurationFile" -Verbose
$LatestAzureConfigurationFile | Get-AzureStorageBlobContent -Destination $TemporaryFolder -Context $Context -Force >$null 2>&1

# Deploy
Write-Output "Creating a new deployment to slot '$CloudServiceSlot' in '$CloudServiceName' with package from '$AzurePackageUrl' and configuration file from '$AzureConfigurationFile'..."
New-AzureDeployment -ServiceName $CloudServiceName -Slot $CloudServiceSlot -Package $AzurePackageUrl -Configuration $AzureConfigurationFile -label "Deployed by automation account" | Out-Null

Write-Verbose "Waiting deployment to complete.." -Verbose
$completeDeployment = Get-AzureDeployment -ServiceName $CloudServiceName -Slot $CloudServiceSlot

$completeDeploymentID = $completeDeployment.DeploymentId
Write-Output "Deployment complete. Deployment ID: $completeDeploymentID"
Remove-Item $AzureConfigurationFile -Force

Write-Verbose "All done!" -Verbose