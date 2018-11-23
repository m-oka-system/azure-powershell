<#
    .DESCRIPTION
        An example runbook which gets all the Classic VMs in a subscription using the Classic Run As Account (certificate)
		and then outputs the VM name and status

    .NOTES
        AUTHOR: Azure Automation Team
        LASTEDIT: 2016-6-1
#>

$ConnectionAssetName = "AzureClassicRunAsConnection"

# Get the connection
$connection = Get-AutomationConnection -Name $connectionAssetName        

# Authenticate to Azure with certificate
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

# Get all VMs in the subscription and write out VM name and status
$VMs = Get-AzureVm  | Select Name, Status
ForEach ($VM in $VMs)
{
    Write-Output ("Classic VM " + $VM.Name + " has status " +  $VM.Status)
}
