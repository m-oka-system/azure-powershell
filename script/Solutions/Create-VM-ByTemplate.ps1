# リソース グループ名
$rg = "AW-RG"

# テンプレート ファイルを使用した仮想マシンの作成
New-AzureRmResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile D:\Solutions\deploy-vm.json `
-TemplateParameterFile D:\Solutions\param-vm-for-web01.json

New-AzureRmResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile D:\Solutions\deploy-vm.json `
-TemplateParameterFile D:\Solutions\param-vm-for-sql01.json

# 作成されたリソースの確認
Get-AzureRmResource | ? {$_.ResourceGroupName -eq $rg } | Select Name, ResourceType
