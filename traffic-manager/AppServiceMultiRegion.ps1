##### Variables

    # ResourceGroup
    $resourceGroupName1 = "w-arm-rg"
    $resourceGroupName2 = "e-arm-rg"
    $location1 = "Japan West"
    $location2 = "Japan East"

    # AppServicePlan
    $appServicePlanName1 = "w-arm-pln"
    $appServicePlanName2 = "e-arm-pln"

    # WebApps
    $webAppName1 = "w-arm-app"
    $webAppName2 = "e-arm-app"

    # TrafficManager
    $profileName = "arm-tm-web"
    $dnsName = "arm-tm-web"
    $webEndPoint1 = "WebEndPoint1"
    $webEndPoint2 = "WebEndPoint2"

   
##### ResourceGroup

    New-AzureRmResourceGroup -Name $resourceGroupName1 -Location $location1 -Verbose -Force
    New-AzureRmResourceGroup -Name $resourceGroupName2 -Location $location2 -Verbose -Force

##### AppService

    # Create AppServicePlan
    $appServicePlan1 = New-AzureRmAppServicePlan -ResourceGroupName $resourceGroupName1 -Location $location1 `
        -Name $appServicePlanName1 -Tier Free -WorkerSize Small -Verbose
    
    $appServicePlan2 = New-AzureRmAppServicePlan -ResourceGroupName $resourceGroupName2 -Location $location2 `
        -Name $appServicePlanName2 -Tier Free -WorkerSize Small -Verbose
    
    # Create WebApps
    $web1 = New-AzureRmWebApp -ResourceGroupName $resourceGroupName1 -Location $location1 `
        -AppServicePlan $appServicePlan1.ServerFarmWithRichSkuName -Name $webAppName1 -Verbose
    
    $web2 = New-AzureRmWebApp -ResourceGroupName $resourceGroupName2 -Location $location2 `
        -AppServicePlan $appServicePlan2.ServerFarmWithRichSkuName -Name $webAppName2 -Verbose

    
##### TrafficManager

    # Create TrafficManagerProfile 
    $tm = New-AzureRmTrafficManagerProfile -ResourceGroupName $resourceGroupName1 `
        -Name $profileName `
        -TrafficRoutingMethod Priority `
        -RelativeDnsName $dnsName -Ttl 60 `
        -MonitorProtocol HTTP -MonitorPort 80 -MonitorPath /
    
    # Create webEndPoint1
    $endPoint1 = New-AzureRmTrafficManagerEndpoint -ResourceGroupName $resourceGroupName1 `
        -Name $webEndPoint1 -ProfileName $tm.Name `
        -Type AzureEndpoints -Priority 1 `
        -TargetResourceId $web1.Id -EndpointStatus Enabled
    
    # Create webEndPoint2
    $endPoint2 = New-AzureRmTrafficManagerEndpoint -ResourceGroupName $resourceGroupName1 `
        -Name $webEndPoint2 -ProfileName $tm.Name `
        -Type AzureEndpoints -Priority 2 `
        -TargetResourceId $web2.Id -EndpointStatus Enabled

##### Clean up

Remove-AzureRmResourceGroup -Name $resourceGroupName1 -Force
Remove-AzureRmResourceGroup -Name $resourceGroupName2 -Force
