# Variables
$resourceGroupName = "w-arm-rg"
$location = "Japan West"
$vmName = "w-arm-vm-1"
$imageName = "WindowsServer2016-ja"

# Generalize Windows VM using Sysprep
# C:\Windows\System32\sysprep\sysprep.exe /generalize /oobe /mode:vm /shutdown

# Unassign the VM
Stop-AzureRmVM -ResourceGroupName $resourceGroupName -Name $vmName -Force

# Set the state of the VM to -Generalized
Set-AzureRmVM -ResourceGroupName $resourceGroupName -Name $vmName -Generalized

# Create image from VM
$vm = Get-AzureRmVM -Name $vmName -ResourceGroupName $resourceGroupName
$image = New-AzureRmImageConfig -Location $location -SourceVirtualMachineId $vm.ID
New-AzureRmImage -Image $image -ImageName $imageName -ResourceGroupName $resourceGroupName

# Create image from vhd
$diskName = $vmName + "-os-disk"
$storageAccountName = "warmstorage123"
$storageAcc = Get-AzureRmStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName
$osDiskUri = $storageAcc.PrimaryEndpoints.Blob.ToString() + "vhds/" + $diskName + ".vhd"
$imageConfig = New-AzureRmImageConfig -Location $location
$imageConfig = Set-AzureRmImageOsDisk -Image $imageConfig -OsType Windows -OsState Generalized -BlobUri $osDiskUri
$image = New-AzureRmImage -ImageName $imageName -ResourceGroupName $resourceGroupName -Image $imageConfig

# Show
Get-AzureRmImage -ResourceGroupName $resourceGroupName

# Delete
Remove-AzureRmImage -ResourceGroupName $resourceGroupName -ImageName $imageName

# Delete all
$array = (Get-AzureRmImage -ResourceGroupName $resourceGroupName).Name
foreach($img in $array){
    Remove-AzureRmImage -ResourceGroupName $resourceGroupName -ImageName $img -Force
}
