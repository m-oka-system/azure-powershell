# Variables
# Common
$rgName = "paas-rg"
$location = "Japan East"

# App Service
$appServicePlanName = "e-paas-pln"
$webAppName = "e-paas-app"

# SQLServer
$sqlServerName = "e-paas-sql"
$sqlLogin = "sqladmin"
$sqlPassword = "1000%kitting"
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $sqlLogin, $(ConvertTo-SecureString -String $sqlPassword -AsPlainText -Force)
$firewallRuleName = "AllowSome"
$startip = "0.0.0.0"
$endip = "0.0.0.0"

# SQLDatabase
$databaseName = "MyDatabase"
$sqlEdition = "S0"
$sqlSize = 250gb

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

# Create sql server
New-AzSqlServer -ResourceGroupName $rgName -Location $location `
    -ServerName $sqlServerName `
    -SqlAdministratorCredentials $cred

# Create firewall rule
New-AzSqlServerFirewallRule -ResourceGroupName $rgName `
    -ServerName $sqlServerName `
    -FirewallRuleName $firewallRuleName -StartIpAddress $startip -EndIpAddress $endip

# Create sql database
New-AzSqlDatabase  -ResourceGroupName $rgName `
    -ServerName $sqlServerName `
    -DatabaseName $databaseName `
    -RequestedServiceObjectiveName $sqlEdition `
    -CollationName "JAPANESE_CI_AS" `
    -MaxSizeBytes $sqlSize

# Delete resource gorup
Remove-AzResourceGroup -Name $rgName -Force