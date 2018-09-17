# Valiables
$resourceGroupName = "w-arm-rg"
$location = "Japan West"
$vmName = "w-arm-vm-1"
$imageName = "WindowsServer2016-ja"
$containerName = "custom-images"
$vhdNamePrefix = "win-jumpbox"

# Generalize Windows VM using Sysprep
# C:\Windows\System32\sysprep\sysprep.exe /generalize /oobe /mode:vm /shutdown

# Unassign the VM
Stop-AzureRmVM -ResourceGroupName $resourceGroupName -Name $vmName -Force

# Set the state of the VM to -Generalized
Set-AzureRmVM -ResourceGroupName $resourceGroupName -Name $vmName -Generalized

# Create vhd image file
Save-AzureRmVMImage -ResourceGroupName $resourceGroupName -Name $vmName `
    -DestinationContainerName $containerName `
    -VHDNamePrefix $vhdNamePrefix
