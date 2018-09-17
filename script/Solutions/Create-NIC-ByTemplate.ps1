# リソース グループ名
$rg = "AW-RG"

# テンプレート ファイルを使用した NIC とパブリック IP アドレスの作成
New-AzureRmResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile D:\Solutions\deploy-nic.json `
-TemplateParameterFile D:\Solutions\param-nic-for-web01.json

New-AzureRmResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile D:\Solutions\deploy-nic.json `
-TemplateParameterFile D:\Solutions\param-nic-for-SQL01.json

# 作成されたリソースの確認
Get-AzureRmResource | ? {$_.ResourceGroupName -eq $rg } | Select Name, ResourceType
