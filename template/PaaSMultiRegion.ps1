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

    # SQLServer with failoverGroup
    $sqlServerName1 = "w-arm-sql"
    $sqlServerName2 = "e-arm-sql"
    $failoverGroupName ="arm-fg"
    $sqlLogin = "sqladmin"
    $sqlPassword = "!PassWord#7" | ConvertTo-SecureString -AsPlainText -Force
    $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $sqlLogin, $(ConvertTo-SecureString -String $sqlPassword -AsPlainText -Force)
    $firewallRuleName = "AllowSome"
    $startip = "0.0.0.0"
    $endip = "0.0.0.0"

    # SQLDatabase
    $databaseName = "mySampleDatabase"
    $sqlEdition = "Basic"
    $sqlSize = 2gb

    # Storage
    $storageAccountName = "warmstorageaccount"

    # VirtualNetwork
    $vnetName = "w-arm-vnet"
    $vnetPrefix = "192.168.0.0/16"
    $subnetName = "subnet1"
    $subnetPrefix = "192.168.1.0/24"

    # TrafficManager
    $profileName = "arm-tm"
    $dnsName = "arm-webapp-tm"
    $endPoint1 = "EndPointWeb1"
    $endPoint2 = "EndPointWeb2"

   
##### ResourceGroup

    New-AzureRmResourceGroup -Name $resourceGroupName1 -Location $location1 -Verbose -Force
    New-AzureRmResourceGroup -Name $resourceGroupName2 -Location $location2 -Verbose -Force


##### Storage

    New-AzureStorageAccount -StorageAccountName $storageAccountName -Location $location1 -Type "Standard_LRS"


##### VirtualNetwork

    # Create VirtualNetwork
    $vnet = New-AzureRmVirtualNetwork -ResourceGroupName $resourceGroupName1 -Location $location1 `
        -Name $vnetName `
        -AddressPrefix $vnetPrefix

    # Create Subnet
    Add-AzureRmVirtualNetworkSubnetConfig `
        -Name $subnetName `
        -VirtualNetwork $vnet `
        -AddressPrefix $subnetPrefix | Set-AzureRmVirtualNetwork


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
    
    # Create Endpoint1
    $endpoint = New-AzureRmTrafficManagerEndpoint -ResourceGroupName $resourceGroupName1 `
        -Name $endPoint1 -ProfileName $tm.Name `
        -Type AzureEndpoints -Priority 1 `
        -TargetResourceId $web1.Id -EndpointStatus Enabled
    
    # Create Endpoint2
    $endpoint2 = New-AzureRmTrafficManagerEndpoint -ResourceGroupName $resourceGroupName1 `
        -Name $endPoint2 -ProfileName $tm.Name `
        -Type AzureEndpoints -Priority 2 `
        -TargetResourceId $web2.Id -EndpointStatus Enabled


##### SQLDatbase

    # Create SQLServer
    New-AzureRmSqlServer -ResourceGroupName $resourceGroupName1 -Location $location1 -ServerName $sqlServerName1 -SqlAdministratorCredentials $cred
    New-AzureRmSqlServer -ResourceGroupName $resourceGroupName2 -Location $location2 -ServerName $sqlServerName2 -SqlAdministratorCredentials $cred

    # Create SQLServer Firewall
    New-AzureRmSqlServerFirewallRule -ResourceGroupName $resourceGroupName1 -ServerName $sqlServerName1 `
        -FirewallRuleName $firewallRuleName -StartIpAddress $startip -EndIpAddress $endip

    New-AzureRmSqlServerFirewallRule -ResourceGroupName $resourceGroupName2 -ServerName $sqlServerName2 `
        -FirewallRuleName $firewallRuleName -StartIpAddress $startip -EndIpAddress $endip

    # Create SQLDatabase
    New-AzureRmSqlDatabase  -ResourceGroupName $resourceGroupName1 `
        -ServerName $sqlServerName1 `
        -DatabaseName $databaseName `
        -RequestedServiceObjectiveName $sqlEdition `
        -CollationName "JAPANESE_CI_AS" `
        -MaxSizeBytes $sqlSize

    # Create FailoverGroup
    New-AzureRMSqlDatabaseFailoverGroup -ResourceGroupName $resourceGroupName1 `
        -ServerName $sqlServerName1 `
        -PartnerResourceGroupName $resourceGroupName2 `
        -PartnerServerName $sqlServerName2 `
        -FailoverGroupName $failoverGroupName `
        -FailoverPolicy Automatic `
        -GracePeriodWithDataLossHours 1

    # Add SQLDatabase to FailoverGroup
    $failoverGroup = Get-AzureRmSqlDatabase -ResourceGroupName $resourceGroupName1 -ServerName $sqlServerName1 -DatabaseName $databaseName | `
        Add-AzureRmSqlDatabaseToFailoverGroup -ResourceGroupName $resourceGroupName1 -ServerName $sqlServerName1 -FailoverGroupName $failoverGroupName


##### Clean up

Remove-AzureRmResourceGroup -Name $resourceGroupName1 -Force
Remove-AzureRmResourceGroup -Name $resourceGroupName2 -Force
