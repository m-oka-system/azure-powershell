# Variables
$resourceGroupName = "w-arm-rg"
$location = "Japan West"
$vmName = "w-arm-vm"
$imageName = "WindowsServer2016-ja"
$containerName = "custom-images"
$vhdNamePrefix = "win-jumpbox"

# Generalize Windows VM using Sysprep
# C:\Windows\System32\sysprep\sysprep.exe /generalize /oobe /mode:vm /shutdown

# Unassign the VM
Stop-AzureRmVM -ResourceGroupName $resourceGroupName -Name $vmName -Force

# Set the state of the VM to -Generalized
Set-AzureRmVM -ResourceGroupName $resourceGroupName -Name $vmName -Generalized

# Show Status
Get-AzureRmVM -ResourceGroupName $resourceGroupName -Name $vmName -Status

# Create an image from unmanaged disk
Save-AzureRmVMImage -ResourceGroupName $resourceGroupName -Name $vmName `
    -DestinationContainerName $containerName `
    -VHDNamePrefix $vhdNamePrefix

# Create an image from managed disk
$vm = Get-AzureRmVM -Name $vmName -ResourceGroupName $resourceGroupName
$image = New-AzureRmImageConfig -Location $location -SourceVirtualMachineId $vm.ID
New-AzureRmImage -Image $image -ImageName $imageName -ResourceGroupName $resourceGroupName
