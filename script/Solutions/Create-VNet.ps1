#リソースグループ
$rg = "AW-RG"
#地域
$location = "japanwest"
# 仮想ネットワーク
$virtualNetworkName = "AW-VNet"
$addressPrefix = "192.168.1.0/25"
# サブネット
$subnet1Name = "Frontend-SN"
$subnet2Name = "Backend-SN"
$subnet1Prefix = "192.168.1.0/27"
$subnet2Prefix = "192.168.1.32/27" 

$vnet = New-AzureRmVirtualNetwork -Location $location -Name $virtualNetworkName `
        -ResourceGroupName $rg -AddressPrefix $addressPrefix

Add-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $subnet1Prefix `
-Name $subnet1Name -VirtualNetwork $vnet
Set-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $subnet1Prefix `
-Name $subnet1Name -VirtualNetwork $vnet
Add-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $subnet2Prefix `
-Name $subnet2Name -VirtualNetwork $vnet
Set-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $subnet2Prefix `
-Name $subnet2Name -VirtualNetwork $vnet
$vnet = Set-AzureRmVirtualNetwork -VirtualNetwork $vnet