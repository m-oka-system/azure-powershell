# Variables
$rgName = "paas-rg"
$location1 = "Japan East"
$location2 = "Japan West"
$appServicePlanName1 = "e-paas-pln"
$appServicePlanName2 = "w-paas-pln"
$webAppName1 = "e-paas-app"
$webAppName2 = "w-paas-app"
$profileName = "paas-tm"
$dnsName = "paas-tm"
$endPoint1 = "East-EndPoint"
$endPoint2 = "West-EndPoint"

# Create resource group
New-AzResourceGroup -Name $rgName -Location $location1 -Verbose -Force

# Create app service plan
$appServicePlan1 = New-AzAppServicePlan -ResourceGroupName $rgName -Location $location1 `
    -Name $appServicePlanName1 -Tier Free -WorkerSize Small -Verbose

$appServicePlan2 = New-AzAppServicePlan -ResourceGroupName $rgName -Location $location2 `
    -Name $appServicePlanName2 -Tier Free -WorkerSize Small -Verbose

# Create web app
$web1 = New-AzWebApp -ResourceGroupName $rgName -Location $location1 `
    -AppServicePlan $appServicePlanName1 -Name $webAppName1 -Verbose

$web2 = New-AzWebApp -ResourceGroupName $rgName -Location $location2 `
    -AppServicePlan $appServicePlanName2 -Name $webAppName2 -Verbose

# Create traffic manager profile (priority)
$tm = New-AzTrafficManagerProfile -ResourceGroupName $rgName `
    -Name $profileName `
    -TrafficRoutingMethod Priority `
    -RelativeDnsName $dnsName -Ttl 60 `
    -MonitorProtocol HTTP -MonitorPort 80 -MonitorPath / -Verbose

# Add primary endpoint
$endpoint = New-AzTrafficManagerEndpoint -ResourceGroupName $rgName `
    -Name $endPoint1 -ProfileName $profileName `
    -Type AzureEndpoints -Priority 1 `
    -TargetResourceId $web1.Id -EndpointStatus Enabled -Verbose

# Add secondary endpoint
$endpoint2 = New-AzTrafficManagerEndpoint -ResourceGroupName $rgName `
    -Name $endPoint2 -ProfileName $profileName `
    -Type AzureEndpoints -Priority 2 `
    -TargetResourceId $web2.Id -EndpointStatus Enabled -Verbose
    
# Publish html file
Publish-AzWebApp -ResourceGroupName $rgName `
    -Name $web1.name -ArchivePath .\traffic-manager\e-paas-app.zip -Force

Publish-AzWebApp -ResourceGroupName $rgName `
    -Name $web2.name -ArchivePath .\traffic-manager\w-paas-app.zip -Force

# Scale app service plan to S1
Set-AzAppServicePlan -ResourceGroupName $rgName `
    -Name $appServicePlanName1 -Tier Standard -WorkerSize Small -Verbose

Set-AzAppServicePlan -ResourceGroupName $rgName `
-Name $appServicePlanName2 -Tier Standard -WorkerSize Small -Verbose

# Scale app service plan to Free
Set-AzAppServicePlan -ResourceGroupName $rgName `
    -Name $appServicePlanName1 -Tier Free -WorkerSize Small -Verbose

Set-AzAppServicePlan -ResourceGroupName $rgName `
    -Name $appServicePlanName2 -Tier Free -WorkerSize Small -Verbose


# Delete endpoint
Remove-AzTrafficManagerEndpoint -Name $endPoint1 -ResourceGroupName $rgName -ProfileName $profileName -Type AzureEndpoints -Force
Remove-AzTrafficManagerEndpoint -Name $endPoint2 -ResourceGroupName $rgName -ProfileName $profileName -Type AzureEndpoints -Force

# Delete traffic manager profile
Remove-AzTrafficManagerProfile -ResourceGroupName $rgName -Name $profileName -Force

# Delete resource gorup
Remove-AzResourceGroup -Name $rgName -Force