# Get Windows Server from ImageFamily list
Get-AzureVMImage | Where-Object {$_.ImageFamily -like "Windows*"} | Select-Object ImageFamily -Unique | Sort-Object ImageFamily

# Variables
$subscriptionId = (Get-AzureSubscription | Select-Object SubscriptionId).SubscriptionId
$storageAccountName = "warmstorageaccount"
$serviceName = "w-arm-cs"
$location = "Japan West"
$vmName = "w-arm-vm01"
$vmSize = "Basic_A0"
$imageFamily = "Windows Server 2012 R2 Datacenter"

# Specify storage account
Set-AzureSubscription –SubscriptionId $subscriptionId –CurrentStorageAccountName $storageAccountName
 
# Set user name and password
$credential = Get-Credential -Message "Type the name and password of the local administrator account."
  
# Define virtual machine settings
$image = Get-AzureVMImage | Where-Object {$_.ImageFamily –eq $imageFamily}| Sort-Object PublishedDate -Descending | Select-Object -ExpandProperty ImageName -First 1
$vmConfig = New-AzureVMConfig -Name $vmName -InstanceSize $vmSize -ImageName $image
$vmConfig | Add-AzureProvisioningConfig -Windows -AdminUsername $credential.UserName -Password $credential.Password
  
# Create Cloud Service
New-AzureService -ServiceName $serviceName -Location $location
  
# Create Virtual Machine
New-AzureVM –ServiceName $serviceName -VMs $vmConfig -Verbose

# Show
Get-AzureVM

# Delete
Remove-AzureVM –ServiceName $serviceName -Name $vmName