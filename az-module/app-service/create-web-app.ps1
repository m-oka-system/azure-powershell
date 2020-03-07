# Variables
$rgName = "paas-rg"
$location = "Japan East"
$appServicePlanName = "e-paas-pln"
$webAppName = "e-paas-app"

# Create resource group
New-AzResourceGroup -Name $rgName -Location $location -Verbose -Force

# Create app service plan
$appServicePlan = New-AzAppServicePlan -ResourceGroupName $rgName -Location $location `
    -Name $appServicePlanName `
    -Tier Free `
    -WorkerSize Small `
    -Verbose

# Create web apps
New-AzWebApp -ResourceGroupName $rgName -Location $location `
    -AppServicePlan $appServicePlanName `
    -Name $webAppName `
    -Verbose

# Show
Get-AzAppServicePlan -Name $appServicePlanName
Get-AzWebApp -Name $webAppName

# Delete web app
Remove-AzWebApp -ResourceGroupName $rgName `
    -Name $webAppName `
    -Force

# Delete app service plan
Remove-AzAppServicePlan -ResourceGroupName $rgName `
    -Name $appServicePlanName `
    -Force

# Delete resource gorup
Remove-AzResourceGroup -Name $rgName -Force