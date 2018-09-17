# リソース グループ名
$rg = "AW-RG"

# テンプレート ファイルを使用したストレージ アカウントの作成
New-AzureRmResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile D:\Solutions\deploy-storage.json

# 作成されたリソースの確認
Get-AzureRmResource | ? {$_.ResourceGroupName -eq $rg } | Select Name, ResourceType