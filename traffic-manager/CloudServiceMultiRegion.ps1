##### Variables

    # ResourceGroup
    $resourceGroupName1 = "w-arm-rg"
    $resourceGroupName2 = "e-arm-rg"
    $location1 = "Japan West"
    $location2 = "Japan East"

    # CloudService
    $serviceName1 = "w-arm-cs"
    $serviceName2 = "e-arm-cs"

    # TrafficManager
    $profileName = "arm-tm-cs"
    $dnsName = "arm-tm-cs"
    $csEndPoint1 = "CSEndPoint1"
    $csEndPoint2 = "CSEndPoint2"
   
##### ResourceGroup

    New-AzureRmResourceGroup -Name $resourceGroupName1 -Location $location1 -Verbose -Force
    New-AzureRmResourceGroup -Name $resourceGroupName2 -Location $location2 -Verbose -Force

##### AppService

    # Create WebApps
    $cs1 = New-AzureService -ServiceName $serviceName1 -Location $location1 -Verbose
    $cs2 = New-AzureService -ServiceName $serviceName2 -Location $location2 -Verbose
    
##### TrafficManager

    # Create TrafficManagerProfile 
    $tm = New-AzureRmTrafficManagerProfile -ResourceGroupName $resourceGroupName1 `
        -Name $profileName `
        -TrafficRoutingMethod Priority `
        -RelativeDnsName $dnsName -Ttl 60 `
        -MonitorProtocol HTTP -MonitorPort 80 -MonitorPath /

    # Create CSEndPoint1
    $endPoint1 = New-AzureRmTrafficManagerEndpoint -ResourceGroupName $resourceGroupName1 `
        -Name $csEndPoint1 -ProfileName $tm.Name `
        -Type ExternalEndpoints  -Priority 1 `
        -EndpointLocation $location1 `
        -Target "${serviceName1}.cloudapp.net" -EndpointStatus Enabled
    
    # Create CSEndPoint2
    $endPoint2 = New-AzureRmTrafficManagerEndpoint -ResourceGroupName $resourceGroupName1 `
        -Name $csEndPoint2 -ProfileName $tm.Name `
        -Type ExternalEndpoints -Priority 2 `
        -Target "${serviceName2}.cloudapp.net" -EndpointStatus Enabled

##### Clean up

Remove-AzureRmResourceGroup -Name $resourceGroupName1 -Force
Remove-AzureRmResourceGroup -Name $resourceGroupName2 -Force
