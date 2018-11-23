# Variables
$resourceGroupName = "w-arm-rg"
$location = "Japan West"
$storageAccountName = "warmstorage123"
$storageAccountType = "Standard_LRS"
$vnetName = "w-arm-vnet"
$vnetPrefix = "192.168.0.0/24"
$subnetName = "subnet1"
$subnetPrefix = "192.168.0.192/27"
$vmName = "w-arm-vm"
$vmSize = "Standard_B1s"
$diskName = $vmName + "-os-disk"
$pip = $vmName + "-pip"
$nic = $vmName + "-nic"
$count = 2

# Create resource group
New-AzureRmResourceGroup -Name $resourceGroupName -Location $location -Verbose -Force

# Create storage account
New-AzureRmStorageAccount -ResourceGroupName $resourceGroupName -Location $location -Name $storageAccountName -Type $storageAccountType -Verbose

# Create Virtual Network
$vnet = New-AzureRmVirtualNetwork -ResourceGroupName $resourceGroupName -Location $location -Name $vnetName -AddressPrefix $vnetPrefix -Verbose

# Add subnet to VNet
Add-AzureRmVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vnet -AddressPrefix $subnetPrefix | Set-AzureRmVirtualNetwork

# Create user object
$cred = Get-Credential -Message "Type the name and password of the local administrator account."

for ($i=1; $i -lt $count; $i++){

    # Create public ip address and network interface
    $vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $resourceGroupName -Name $vnetName
    $pip = New-AzureRmPublicIpAddress -ResourceGroupName $resourceGroupName -Location $location -Name $pip -AllocationMethod Dynamic
    $nic = New-AzureRmNetworkInterface -ResourceGroupName $resourceGroupName -Location $location -Name $nic -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id

    # Create VM configuration
    $vm = New-AzureRmVMConfig -VMName "$vmName + $i" -VMSize $vmSize
    $vm = Set-AzureRmVMOperatingSystem -VM $vm -Windows -ComputerName "$vmName + $i" -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
    $vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id
    $vm = Set-AzureRmVMSourceImage -VM $vm -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2016-Datacenter" -Version "latest"

    # Set storage location and virtual disk name for saving image of VM
    $storageAcc = Get-AzureRmStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName
    $osDiskUri = $storageAcc.PrimaryEndpoints.Blob.ToString() + "vhds/" + $diskName + ".vhd"
    $vm = Set-AzureRmVMOSDisk -VM $vm -Name $diskName -VhdUri $osDiskUri -CreateOption fromImage

    # Create VM
    New-AzureRmVM -ResourceGroupName $resourceGroupName -Location $location -VM $vm
}