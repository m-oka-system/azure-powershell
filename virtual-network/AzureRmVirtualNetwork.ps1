# Variables
$resourceGroupName = "w-arm-rg"
$location = "Japan West"
$vnetName = "w-arm-vnet"
$vnetPrefix = "192.168.0.0/24"
$subnetName = "subnet1"
$subnetPrefix = "192.168.0.192/27"

# Create Resource Group
New-AzureRmResourceGroup -Name $resourceGroupName -Location $location -Verbose -Force

# Create Virtual Network
$vnet = New-AzureRmVirtualNetwork -ResourceGroupName $resourceGroupName -Location $location `
    -Name $vnetName `
    -AddressPrefix $vnetPrefix -Verbose

# Add subnet to VNet
Add-AzureRmVirtualNetworkSubnetConfig `
    -Name $subnetName `
    -VirtualNetwork $vnet `
    -AddressPrefix $subnetPrefix | Set-AzureRmVirtualNetwork

# Show
$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $resourceGroupName -Name $vnetName
Get-AzureRmVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vnet

# Delete
Remove-AzureRmVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vnet | Set-AzureRmVirtualNetwork
Remove-AzureRmVirtualNetwork -ResourceGroupName $resourceGroupName -Name $vnetName -Force

