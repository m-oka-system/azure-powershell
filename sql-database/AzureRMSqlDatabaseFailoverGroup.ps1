## Variables
# ResourceGroup
$resourceGroupName = "w-arm-rg"
$partnerResourceGroupName = "e-arm-rg"
$location = "Japan West"
$partnerLocation = "Japan East"

# SQLServer
$sqlServerName = "w-arm-sql"
$partnerSqlServerName = "e-arm-sql"
$sqlLogin = "sqladmin"
$sqlPassword = "yourpassword"
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $sqlLogin, $(ConvertTo-SecureString -String $sqlPassword -AsPlainText -Force)
$firewallRuleName = "AllowSome"
$startip = "0.0.0.0"
$endip = "0.0.0.0"

# SQLDatabase
$databaseName = "MyDatabase"
$sqlEdition = "Basic"
$sqlSize = 2gb

# failover group
$failoverGroupName ="arm-fo"

# Create resource group
New-AzureRmResourceGroup -Name $resourceGroupName -Location $location -Verbose -Force
New-AzureRmResourceGroup -Name $partnerResourceGroupName -Location $partnerLocation -Verbose -Force

# Create sql server
New-AzureRmSqlServer -ResourceGroupName $resourceGroupName -Location $location `
    -ServerName $sqlServerName `
    -SqlAdministratorCredentials $cred -Verbose

New-AzureRmSqlServer -ResourceGroupName $partnerResourceGroupName -Location $partnerLocation `
    -ServerName $partnerSqlServerName `
    -SqlAdministratorCredentials $cred -Verbose

# Create firewall rule
New-AzureRmSqlServerFirewallRule -ResourceGroupName $resourceGroupName `
    -ServerName $sqlServerName `
    -FirewallRuleName $firewallRuleName -StartIpAddress $startip -EndIpAddress $endip -Verbose

New-AzureRmSqlServerFirewallRule -ResourceGroupName $partnerResourceGroupName `
    -ServerName $partnerSqlServerName `
    -FirewallRuleName $firewallRuleName -StartIpAddress $startip -EndIpAddress $endip -Verbose

# Create sql database
New-AzureRmSqlDatabase  -ResourceGroupName $resourceGroupName `
    -ServerName $sqlServerName `
    -DatabaseName $databaseName `
    -RequestedServiceObjectiveName $sqlEdition `
    -CollationName "JAPANESE_CI_AS" `
    -MaxSizeBytes $sqlSize -Verbose

# Create failover group
New-AzureRmSqlDatabaseFailoverGroup -ResourceGroupName $resourceGroupName `
    -ServerName $sqlServerName `
    -PartnerResourceGroupName $partnerResourceGroupName `
    -PartnerServerName $partnerSqlServerName `
    -FailoverGroupName $failoverGroupName `
    -FailoverPolicy Automatic `
    -GracePeriodWithDataLossHours 1 -Verbose

# Add Database to failover group
$failoverGroup = Get-AzureRmSqlDatabase -ResourceGroupName $resourceGroupName -ServerName $sqlServerName -DatabaseName $databaseName | `
    Add-AzureRmSqlDatabaseToFailoverGroup -ResourceGroupName $resourceGroupName -ServerName $sqlServerName -FailoverGroupName $failoverGroupName -Verbose

# Show
Get-AzureRmSqlServer -ResourceGroupName $resourceGroupName -ServerName $sqlServerName
Get-AzureRmSqlServerFirewallRule -ResourceGroupName $resourceGroupName -ServerName $sqlServerName
Get-AzureRmSqlDatabase -ResourceGroupName $resourceGroupName -ServerName $sqlServerName

# Delete 
$failoverGroup = Get-AzureRmSqlDatabase -ResourceGroupName $resourceGroupName -ServerName $sqlServerName -DatabaseName $databaseName | `
    Remove-AzureRmSqlDatabaseFromFailoverGroup -ResourceGroupName $resourceGroupName -ServerName $sqlServerName -FailoverGroupName $failoverGroupName -Verbose

Remove-AzureRmSqlDatabaseFailoverGroup -ResourceGroupName $resourceGroupName `
    -ServerName $sqlServerName `
    -FailoverGroupName $failoverGroupName -Verbose

Remove-AzureRmSqlDatabase -ResourceGroupName $partnerResourceGroupName -ServerName $partnerSqlServerName -DatabaseName $databaseName -Verbose
Remove-AzureRmSqlServerFirewallRule $partnerResourceGroupName -ServerName $partnerSqlServerName -FirewallRuleName $firewallRuleName -Verbose
Remove-AzureRmSqlServer -ResourceGroupName $partnerResourceGroupName -ServerName $partnerSqlServerName -Verbose

Remove-AzureRmSqlDatabase -ResourceGroupName $resourceGroupName -ServerName $sqlServerName -DatabaseName $databaseName -Verbose
Remove-AzureRmSqlServerFirewallRule $resourceGroupName -ServerName $sqlServerName -FirewallRuleName $firewallRuleName -Verbose
Remove-AzureRmSqlServer -ResourceGroupName $resourceGroupName -ServerName $sqlServerName -Verbose
