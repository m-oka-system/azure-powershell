# Variables
$resourceGroupName = "w-arm-rg"
$location = "Japan West"
$appServicePlanName = "w-arm-pln"
$webAppName = "w-arm-app"

# Create resource group
New-AzureRmResourceGroup -Name $resourceGroupName -Location $location -Verbose -Force

# Create app service plan
$appServicePlan = New-AzureRmAppServicePlan -ResourceGroupName $resourceGroupName -Location $location `
    -Name $appServicePlanName `
    -Tier Free `
    -WorkerSize Small `
    -Verbose

# Create web apps
New-AzureRmWebApp -ResourceGroupName $resourceGroupName -Location $location `
    -AppServicePlan $appServicePlan.ServerFarmWithRichSkuName `
    -Name $webAppName `
    -Verbose

# Show
Get-AzureRmAppServicePlan -Name $appServicePlanName
Get-AzureRmWebApp -Name $webAppName

# Delete web app
Remove-AzureRmWebApp -ResourceGroupName $resourceGroupName `
    -Name $webAppName `
    -Force

# Delete app service plan
Remove-AzureRmAppServicePlan -ResourceGroupName $resourceGroupName `
    -Name $appServicePlanName `
    -Force