# Variables
$resourceGroupName = "w-arm-rg"
$vmName = "w-arm-vm"

# Create remote desktop file
Get-AzureRmRemoteDesktopFile -ResourceGroupName $resourceGroupName -Name $vmName -Launch