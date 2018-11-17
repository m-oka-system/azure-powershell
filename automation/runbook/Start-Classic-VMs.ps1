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

# Start each of the stopped VMs
foreach ($VM in $VMs)
{
  if ($VM.PowerState -eq "Started")
  {
    # The VM is already started, so send notice
    Write-Output ($VM.InstanceName + " is already running")
  }
  else
  {
    # The VM needs to be started
    $StartRtn = Start-AzureVM -Name $VM.Name -ServiceName $VM.ServiceName -ErrorAction Continue
    if ($StartRtn.OperationStatus -ne 'Succeeded')
    {
      # The VM failed to start, so send notice
      Write-Output ($VM.InstanceName + " failed to start")
    }
    else
    {
      # The VM started, so send notice
      Write-Output ($VM.InstanceName + " has been started")
    }
  }
}