$resourceGroupDeploymentName ="ExampleDeploy"
$resourceGroupName = "e-arm-rg"
$location = "Japan East"
$template = ""

#リソースグループを作成
New-AzureRmResourceGroup -Name $resourceGroupName -Location $location -Verbose -Force

#デプロイ
New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName `
    -Name $resourceGroupDeploymentName `
    -TemplateFile $template `
    -Verbose -Force