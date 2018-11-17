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

# Get all VMs in the subscription
$VMs = Get-AzureVM

# Stop each of the started VMs
foreach ($VM in $VMs)
{
  if ($VM.PowerState -eq "Stopped")
  {
    # The VM is already stopped, so send notice
    Write-Output ($VM.InstanceName + " is already stopped")
  }
  else
  {
    # The VM needs to be stopped
    $StopRtn = Stop-AzureVM -Name $VM.Name -ServiceName $VM.ServiceName -Force -ErrorAction Continue
    if ($StopRtn.OperationStatus -ne 'Succeeded')
    {
      # The VM failed to stop, so send notice
      Write-Output ($VM.InstanceName + " failed to stop")
    }
    else
    {
      # The VM stopped, so send notice
      Write-Output ($VM.InstanceName + " has been stopped")
    }
  }
}
