# リソースグループ
$rg = "AW-RG"
# 仮想マシンの停止
Get-AzureRmVM -ResourceGroupName $rg | select name | Stop-AzureRmVM  -ResourceGroupName $rg