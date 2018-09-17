# リソースグループ
$rg = "AW-RG"

# リソース グループの削除
Remove-AzureRmResourceGroup -Name $rg
# リソースグループの確認
Get-AzureRmResourceGroup | Select ResourceGroupName