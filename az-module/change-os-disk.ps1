Add-AzAccount

$resourceGroupName = "w-iaas-rg"
$vmName = "w-iaas-vm-02"
$newDisk = "w-iaas-vm-02_OsDisk_1_8cc8c5b03161451da28e91204bf49979"

Get-AzDisk -ResourceGroupName $resourceGroupName | Format-Table -Property Name

# Get the VM 
$vm = Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName

# Make sure the VM is stopped\deallocated
Stop-AzVM -ResourceGroupName $resourceGroupName -Name $vm.Name -Force

# Get the new disk that you want to swap in
$disk = Get-AzDisk -ResourceGroupName $resourceGroupName -Name $newDisk

# Set the VM configuration to point to the new disk  
Set-AzVMOSDisk -VM $vm -ManagedDiskId $disk.Id -Name $disk.Name 

# Update the VM with the new OS disk
Update-AzVM -ResourceGroupName $resourceGroupName -VM $vm 

# Start the VM
Start-AzVM -Name $vm.Name -ResourceGroupName $resourceGroupName