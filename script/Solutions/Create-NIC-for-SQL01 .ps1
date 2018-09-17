#リソースグループ
$rg = "AW-RG"
#地域
$location = "japanwest"
# パブリックIPアドレス
$PublicIpAddressName = "SQL01-IP"
$dnsNameforPublicIp = "aw-sql-ps"
$allocationMethod = "Dynamic"
# 仮想ネットワーク
$virtualNetworkName = "AW-VNet"
$subnetName = "Backend-SN"
# NIC
$nicName = "SQL01-NIC"
$privateIpAddress = "192.168.1.36"

# パブリック IP アドレスの作成
$pip = New-AzureRmPublicIpAddress `
      -AllocationMethod $allocationMethod -ResourceGroupName $rg `
      -DomainNameLabel $dnsNameforPublicIP `
      -Location $location -Name $PublicIPAddressName
# NIC を配置するサブネットの取得
$vnet = Get-AzureRmVirtualNetwork -Name $virtualNetworkName `
       -ResourceGroupName $rg
$subnet = Get-AzureRmVirtualNetworkSubnetConfig -Name $subnetName `
         -VirtualNetwork $vnet
# NIC の作成
$nic = New-AzureRmNetworkInterface -ResourceGroupName $rg `
      -Location $location -Name $nicName -Subnet $subnet `
      -PrivateIpAddress $privateIpAddress -PublicIpAddress $pip