# Variables
# Common
$rgName = "paas-rg"
$location1 = "Japan East"
$location2 = "Japan West"

# AppService
$appServicePlanName1 = "e-paas-pln"
$appServicePlanName2 = "w-paas-pln"
$webAppName1 = "e-paas-app"
$webAppName2 = "w-paas-app"
$fqdn = "www.udemy-azure-paas.xyz"
$gitRepositoryPath = "https://github.com/Azure-Samples/dotnet-sqldb-tutorial.git"

# TrafficManger
$profileName = "paas-tm"
$dnsName = "paas-tm"
$endPoint1 = "East-EndPoint"
$endPoint2 = "West-EndPoint"

# SQLServer
$sqlServerName1 = "e-paas-sql"
$sqlServerName2 = "w-paas-sql"
$sqlLogin = "sqladmin"
$sqlPassword = "My5up3rStr0ngPaSw0rd!"
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $sqlLogin, $(ConvertTo-SecureString -String $sqlPassword -AsPlainText -Force)
$firewallRuleName = "AllowSome"
$startIp = "0.0.0.0"
$endIp = "0.0.0.0"

# SQLDatabase
$databaseName = "MyDatabase"
$sqlEdition = "Basic" #"S0"
$sqlSize = 2gb

# Failover group
$failoverGroupName ="paas-fog"

# Create resource group
New-AzResourceGroup -Name $rgName -Location $location1 -Verbose -Force

# Create app service plan
New-AzAppServicePlan -ResourceGroupName $rgName -Location $location1 `
    -Name $appServicePlanName1 -Tier Free -WorkerSize Small -Verbose

New-AzAppServicePlan -ResourceGroupName $rgName -Location $location2 `
    -Name $appServicePlanName2 -Tier Free -WorkerSize Small -Verbose

# Create web app
$web1 = New-AzWebApp -ResourceGroupName $rgName -Location $location1 `
    -AppServicePlan $appServicePlanName1 -Name $webAppName1 -Verbose

$web2 = New-AzWebApp -ResourceGroupName $rgName -Location $location2 `
    -AppServicePlan $appServicePlanName2 -Name $webAppName2 -Verbose

# Create traffic manager profile (priority)
New-AzTrafficManagerProfile -ResourceGroupName $rgName `
    -Name $profileName `
    -TrafficRoutingMethod Priority `
    -RelativeDnsName $dnsName -Ttl 0 `
    -MonitorProtocol HTTP -MonitorPort 80 -MonitorPath / -Verbose

# Add primary endpoint
New-AzTrafficManagerEndpoint -ResourceGroupName $rgName `
    -Name $endPoint1 -ProfileName $profileName `
    -Type AzureEndpoints -Priority 1 `
    -TargetResourceId $web1.Id -EndpointStatus Enabled -Verbose

# Add secondary endpoint
New-AzTrafficManagerEndpoint -ResourceGroupName $rgName `
    -Name $endPoint2 -ProfileName $profileName `
    -Type AzureEndpoints -Priority 2 `
    -TargetResourceId $web2.Id -EndpointStatus Enabled -Verbose

# Scale app service plan to S1
Set-AzAppServicePlan -ResourceGroupName $rgName `
    -Name $appServicePlanName1 -Tier Standard -WorkerSize Small -Verbose

Set-AzAppServicePlan -ResourceGroupName $rgName `
    -Name $appServicePlanName2 -Tier Standard -WorkerSize Small -Verbose

# Add a custom domain name to the web app
Set-AzWebApp -Name $webAppName1 -ResourceGroupName $rgName `
    -HostNames @($fqdn,"$webAppName1.azurewebsites.net","$profileName.trafficmanager.net","$webAppName1.azurewebsites.net")

Set-AzWebApp -Name $webAppName2 -ResourceGroupName $rgName `
    -HostNames @($fqdn,"$webAppName2.azurewebsites.net","$profileName.trafficmanager.net","$webAppName2.azurewebsites.net")

# Create sql server
# Primary
New-AzSqlServer -ResourceGroupName $rgName -Location $location1 `
    -ServerName $sqlServerName1 `
    -SqlAdministratorCredentials $cred -Verbose
# Secondary
New-AzSqlServer -ResourceGroupName $rgName -Location $location2 `
    -ServerName $sqlServerName2 `
    -SqlAdministratorCredentials $cred -Verbose

# Create firewall rule to allow connections from Azure services
# Primary
New-AzSqlServerFirewallRule -ResourceGroupName $rgName `
    -ServerName $sqlServerName1 `
    -FirewallRuleName $firewallRuleName -StartIpAddress $startip -EndIpAddress $endIp -Verbose

# Secondary
New-AzSqlServerFirewallRule -ResourceGroupName $rgName `
    -ServerName $sqlServerName2 `
    -FirewallRuleName $firewallRuleName -StartIpAddress $startip -EndIpAddress $endIp -Verbose

# Create sql database
New-AzSqlDatabase  -ResourceGroupName $rgName `
    -ServerName $sqlServerName1 `
    -DatabaseName $databaseName `
    -RequestedServiceObjectiveName $sqlEdition `
    -CollationName "JAPANESE_CI_AS" `
    -MaxSizeBytes $sqlSize -Verbose

# Create failover group
New-AzSqlDatabaseFailoverGroup -ResourceGroupName $rgName `
    -ServerName $sqlServerName1 `
    -PartnerResourceGroupName $rgName `
    -PartnerServerName $sqlServerName2 `
    -FailoverGroupName $failoverGroupName `
    -FailoverPolicy Automatic `
    -GracePeriodWithDataLossHours 1 -Verbose

# Add Database to failover group
Get-AzSqlDatabase -ResourceGroupName $rgName -ServerName $sqlServerName1 -DatabaseName $databaseName | `
    Add-AzSqlDatabaseToFailoverGroup -ResourceGroupName $rgName -ServerName $sqlServerName1 -FailoverGroupName $failoverGroupName -Verbose

# Assign Connection String to Connection String 
# Set-AzWebApp -ConnectionStrings @{ MyDbConnection = @{ Type="SQLAzure"; Value ="Server=tcp:$failoverGroupName.database.windows.net;Database=$databaseName;User ID=$sqlLogin@$failoverGroupName;Password=$sqlPassword;Trusted_Connection=False;Encrypt=True;" } } -Name $webAppName1 -ResourceGroupName $rgName
Set-AzWebApp -ConnectionStrings @{ MyDbConnection = @{ Type="SQLAzure"; Value ="Server=tcp:$failoverGroupName.database.windows.net,1433;Initial Catalog=$databaseName;Persist Security Info=False;User ID=$sqlLogin;Password=$sqlPassword;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;" } } -Name $webAppName1 -ResourceGroupName $rgName
Set-AzWebApp -ConnectionStrings @{ MyDbConnection = @{ Type="SQLAzure"; Value ="Server=tcp:$failoverGroupName.database.windows.net,1433;Initial Catalog=$databaseName;Persist Security Info=False;User ID=$sqlLogin;Password=$sqlPassword;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;" } } -Name $webAppName2 -ResourceGroupName $rgName

# Clone Todo app
git clone $gitRepositoryPath
cd dotnet-sqldb-tutorial/

# git config
git remote add east https://$webAppName1.scm.azurewebsites.net:443/$webAppName1.git
git remote add west https://$webAppName2.scm.azurewebsites.net:443/$webAppName2.git
git config --global user.name "your name"
git config --global user.email "your email"

# git gush
git push east master
git push west master
