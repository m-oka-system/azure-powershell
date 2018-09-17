# Valiables
$resourceGroupName1 = "w-arm-rg"
$resourceGroupName2 = "e-arm-rg"
$location1 = "Japan West"
$location2 = "Japan East"
$appServicePlanName1 = "w-arm-pln"
$appServicePlanName2 = "e-arm-pln"
$webAppName1 = "w-arm-app"
$webAppName2 = "e-arm-app"
$profileName = "arm-tm"
$dnsName = "arm-tm-web"
$endPoint1 = "MyEndPoint1"
$endPoint2 = "MyEndPoint2"

# Create resource group
New-AzureRmResourceGroup -Name $resourceGroupName1 -Location $location1 -Verbose -Force
New-AzureRmResourceGroup -Name $resourceGroupName2 -Location $location2 -Verbose -Force

# Create app service plan
$appServicePlan1 = New-AzureRmAppServicePlan -ResourceGroupName $resourceGroupName1 -Location $location1 `
    -Name $appServicePlanName1 -Tier Free -WorkerSize Small -Verbose

$appServicePlan2 = New-AzureRmAppServicePlan -ResourceGroupName $resourceGroupName2 -Location $location2 `
    -Name $appServicePlanName2 -Tier Free -WorkerSize Small -Verbose

# Create web apps
$web1 = New-AzureRmWebApp -ResourceGroupName $resourceGroupName1 -Location $location1 `
    -AppServicePlan $appServicePlan1.ServerFarmWithRichSkuName -Name $webAppName1 -Verbose

$web2 = New-AzureRmWebApp -ResourceGroupName $resourceGroupName2 -Location $location2 `
    -AppServicePlan $appServicePlan2.ServerFarmWithRichSkuName -Name $webAppName2 -Verbose

# Create traffic manager profile (priority)
$tm = New-AzureRmTrafficManagerProfile -ResourceGroupName $resourceGroupName1 `
    -Name $profileName `
    -TrafficRoutingMethod Priority `
    -RelativeDnsName $dnsName -Ttl 60 `
    -MonitorProtocol HTTP -MonitorPort 80 -MonitorPath / -Verbose

# Add primary endpoint
$endpoint = New-AzureRmTrafficManagerEndpoint -ResourceGroupName $resourceGroupName1 `
    -Name $endPoint1 -ProfileName $tm.Name `
    -Type AzureEndpoints -Priority 1 `
    -TargetResourceId $web1.Id -EndpointStatus Enabled -Verbose

# Add secondary endpoint
$endpoint2 = New-AzureRmTrafficManagerEndpoint -ResourceGroupName $resourceGroupName1 `
    -Name $endPoint2 -ProfileName $tm.Name `
    -Type AzureEndpoints -Priority 2 `
    -TargetResourceId $web2.Id -EndpointStatus Enabled -Verbose

# Delete endpoint
Remove-AzureRmTrafficManagerEndpoint -Name $endPoint1 -ResourceGroupName $resourceGroupName1 -ProfileName $profileName -Type AzureEndpoints -Force
Remove-AzureRmTrafficManagerEndpoint -Name $endPoint2 -ResourceGroupName $resourceGroupName1 -ProfileName $profileName -Type AzureEndpoints -Force

# Delete traffic manager profile
Remove-AzureRmTrafficManagerProfile -ResourceGroupName $resourceGroupName1 -Name $profileName -Force

