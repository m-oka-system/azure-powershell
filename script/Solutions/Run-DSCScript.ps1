# リソース グループ名
$rg = "AW-RG"

# テンプレート ファイルを使用した IIS のインストール
New-AzureRmResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile D:\Solutions\install-iis.json `
-TemplateParameterFile D:\Solutions\param-iis-for-web01.json