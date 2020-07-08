# Variables
$rgName = "w-iaas-rg"
$location = "Japan West"
$vnetName = "w-iaas-vnet"
$vmName = "w-iaas-vm-01"
$vmSize = "Standard_F1"
$diskName = $vmName + "-os-disk"
$diskType = "Premium_LRS" #Standard_LRS
$diskSize = 32
$pipName = $vmName + "-pip"
$nicName = $vmName + "-nic"
$privateIP = "10.0.1.10"
$imageName = "w-iaas-win2016-ja-image"
$imageId = (Get-AzImage -ResourceGroupName $rgName -ImageName $imageName).Id
$adminUser = "cloudadmin"
$adminPassword = ConvertTo-SecureString "InputYourPassword!" -AsPlainText -Force
$osCreateOption = "FromImage"

# Create public ip address and network interface
$vnet = Get-AzVirtualNetwork -ResourceGroupName $rgName -Name $vnetName
$pip = New-AzPublicIpAddress -ResourceGroupName $rgName -Location $location -Name $pipName -AllocationMethod Dynamic
$nic = New-AzNetworkInterface -ResourceGroupName $rgName -Location $location -Name $nicName -SubnetId $vnet.Subnets[0].Id -PrivateIpAddress $privateIP -PublicIpAddressId $pip.Id

# Create user object
$cred = New-Object System.Management.Automation.PSCredential ($adminUser, $adminPassword)

# Create VM configuration
$vm = New-AzVMConfig -VMName $vmName -VMSize $vmSize -Priority "Spot" -MaxPrice -1
$vm = Set-AzVMOperatingSystem -VM $vm -Windows -ComputerName $vmName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
$vm = Add-AzVMNetworkInterface -VM $vm -Id $nic.Id
$vm = Set-AzVMSourceImage -VM $vm -Id $imageId
$vm = Set-AzVMOSDisk -VM $vm -Name $diskName -DiskSizeInGB $diskSize -StorageAccountType $diskType -CreateOption $osCreateOption -Windows

# Create VM
New-AzVM -ResourceGroupName $rgName -Location $location -VM $vm -Verbose
