# Variables
$serviceName = "w-arm-cs"
$vmName = "w-arm-vm01"

# Create remote desktop file
Get-AzureRemoteDesktopFile -ServiceName $serviceName -Name $vmName -Launch