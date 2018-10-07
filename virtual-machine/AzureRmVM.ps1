# Variables
$resourceGroupName = "w-arm-rg"
$location = "Japan West"
$vmName = "w-arm-vm-1"
$vmSize = "Basic_A1"
$diskName = $vmName + "-os-disk"
$pip = $vmName + "-pip"
$nic = $vmName + "-nic"
$vnetName = "w-arm-vnet"
$storageAccountName = "warmstorage123"

# Create resource group
New-AzureRmResourceGroup -Name $resourceGroupName -Location $location -Verbose -Force

# Create public ip address and network interface
$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $resourceGroupName -Name $vnetName
$pip = New-AzureRmPublicIpAddress -ResourceGroupName $resourceGroupName -Location $location -Name $pip -AllocationMethod Dynamic
$nic = New-AzureRmNetworkInterface -ResourceGroupName $resourceGroupName -Location $location -Name $nic -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id

# Create user object
$cred = Get-Credential -Message "Type the name and password of the local administrator account."

# Serach size
# Get-AzureRmVMSize -Location $location

# Serach Skus
# Get-AzureRMVMImageSku -Location $location -Offer "WindowsServer" -PublisherName "MicrosoftWindowsServer"

# Create VM configuration
$vm = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize
$vm = Set-AzureRmVMOperatingSystem -VM $vm -Windows -ComputerName $vmName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id
$vm = Set-AzureRmVMSourceImage -VM $vm -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2016-Datacenter" -Version "latest"

# Set storage location and virtual disk name for saving image of VM
$storageAcc = Get-AzureRmStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName
$osDiskUri = $storageAcc.PrimaryEndpoints.Blob.ToString() + "vhds/" + $diskName + ".vhd"
$vm = Set-AzureRmVMOSDisk -VM $vm -Name $diskName -VhdUri $osDiskUri -CreateOption fromImage

# Create VM
New-AzureRmVM -ResourceGroupName $resourceGroupName -Location $location -VM $vm

# Show
Get-AzureRmVM -ResourceGroupName $resourceGroupName -Status