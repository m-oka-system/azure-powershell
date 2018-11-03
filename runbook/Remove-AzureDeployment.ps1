Param( 
	 	
	[Parameter (Mandatory = $true)] 
	[string]$CloudServiceName,
	
	[Parameter (Mandatory = $true)] 
	[ValidateSet("staging","production")]
	[string]$CloudServiceSlot
)

$ErrorActionPreference = 'Stop'

function Login() {
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
}
 
Login

Write-Verbose "Searching deployments from slot '$CloudServiceSlot' in '$CloudServiceName'" -Verbose
$deployments = Get-AzureDeployment -ServiceName $CloudServiceName -slot $CloudServiceSlot -ErrorAction "SilentlyContinue"

if ($deployments) {
	Write-Output "Stopping Cloud Service '$CloudServiceName' in slot '$CloudServiceSlot'"
	Stop-AzureService $CloudServiceName -Slot $CloudServiceSlot
	
	Write-Output "Removing Cloud Service deployment '$CloudServiceName' in slot '$CloudServiceSlot'"
	Remove-AzureDeployment $CloudServiceName -Slot $CloudServiceSlot -Force | Out-Null
} 
else 
{
	Write-Warning "No deployment found from '$CloudServiceName' in slot '$CloudServiceSlot' that we could remove"
}

Write-Verbose "All done!" -Verbose
