# Variables
$resourceGroupName = "w-arm-rg"
$location = "Japan West"
$vnetName = "w-arm-vnet"
$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $resourceGroupName -Name $vnetName
$nsgName = "w-arm-nsg"
$ruleName = "rdp-access-rule"

# Create network security group (NSG)
$nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $resourceGroupName -Location $location `
    -Name $nsgName
 
# Add rule to NSG
$nsg | Add-AzureRmNetworkSecurityRuleConfig `
    -Name $ruleName `
    -DestinationAddressPrefix "*" `
    -DestinationPortRange "3389" `
    -Access Allow `
    -Priority 100 `
    -Direction Inbound `
    -Protocol Tcp `
    -SourceAddressPrefix Internet `
    -SourcePortRange "*"

# Update NSG rules
Set-AzureRmNetworkSecurityGroup -NetworkSecurityGroup $nsg

# Apply NSG to subnet
Set-AzureRmVirtualNetworkSubnetConfig `
    -VirtualNetwork $vnet `
    -Name $subnetName `
    -AddressPrefix $subnetPrefix `
    -NetworkSecurityGroup $nsg | Set-AzureRmVirtualNetwork

# Show
Get-AzureRmNetworkSecurityGroup -Name $nsgName -ResourceGroupName $resourceGroupName
Get-AzureRmNetworkSecurityRuleConfig -NetworkSecurityGroup $nsg
Get-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $vnet

# Remove NSG from subnet
$subnet = Get-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $vnet
$subnet.NetworkSecurityGroup = $null
Set-AzureRmVirtualNetwork -VirtualNetwork $vnet

# Delete
Remove-AzureRmNetworkSecurityRuleConfig -NetworkSecurityGroup $nsg
Remove-AzureRmNetworkSecurityGroup -Name $nsgName -ResourceGroupName $resourceGroupName -Force
