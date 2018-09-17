# リソース グループ名
$rg = "AW-RG"

# テンプレート ファイルを使用した仮想ネットワークの作成
New-AzureRmResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile D:\Solutions\deploy-vnet.json

# 作成されたリソースの確認
Get-AzureRmResource | ? {$_.ResourceGroupName -eq $rg } | Select Name, ResourceType