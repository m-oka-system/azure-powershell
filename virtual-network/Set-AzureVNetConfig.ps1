# Export network configuration file
Get-AzureVNetConfig -ExportToFile "C:\azure\vnet.xml"

# Update virtual network based on network configuration file
Set-AzureVNetConfig -ConfigurationPath "C:\azure\vnet.xml"

# Valiables
$resourceGroupName = "w-arm-rg"
$vnetName = "w-arm-vnet"
$vnetName = "Group " + "${resourceGroupName} " + $vnetName

# Create vpn gateway
New-AzureVNetGateway -VNetName $vnetName -GatewayType DynamicRouting -GatewaySKU Default

# Show
Get-AzureVNetGateway -VNetName $vnetName
Get-AzureVNetSite -VNetName $vnetName

# delete
Remove-AzureVNetGateway -VNetName $vnetName

# Show shared key
Get-AzureVNetGatewayKey -VNetName $vnetName -LocalNetworkSiteName <localsitename>