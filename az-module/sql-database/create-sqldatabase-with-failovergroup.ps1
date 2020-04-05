# Variables

# ResourceGroup
$rgName = "paas-rg"
$location = "Japan East"
$secondaryLocation = "Japan West"

# SQLServer
$sqlServerName = "e-paas-sql"
$secondarySqlServerName = "w-paas-sql"
$sqlLogin = "sqladmin"
$sqlPassword = "input your password"
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $sqlLogin, $(ConvertTo-SecureString -String $sqlPassword -AsPlainText -Force)
$firewallRuleName = "AllowSome"
$startip = "0.0.0.0"
$endip = "0.0.0.0"
$myip = "input your ip address"

# SQLDatabase
$databaseName = "MyDatabase"
$sqlEdition = "Basic" #"S0"
$sqlSize = 2gb

# failover group
$failoverGroupName ="paas-fog"

# Create resource group
New-AzResourceGroup -Name $rgName -Location $location -Verbose -Force

# Create sql server
# Primary
New-AzSqlServer -ResourceGroupName $rgName -Location $location `
    -ServerName $sqlServerName `
    -SqlAdministratorCredentials $cred
# Secondary
New-AzSqlServer -ResourceGroupName $rgName -Location $secondaryLocation `
    -ServerName $secondarySqlServerName `
    -SqlAdministratorCredentials $cred

# Create firewall rule to allow connections from Azure services and client IP address
# Primary
New-AzSqlServerFirewallRule -ResourceGroupName $rgName `
    -ServerName $sqlServerName `
    -FirewallRuleName $firewallRuleName -StartIpAddress $startip -EndIpAddress $endip

New-AzSqlServerFirewallRule -ResourceGroupName $rgName `
    -ServerName $sqlServerName `
    -FirewallRuleName "ClientIPAddress" -StartIpAddress $myip -EndIpAddress $myip

# Secondary
New-AzSqlServerFirewallRule -ResourceGroupName $rgName `
    -ServerName $secondarySqlServerName `
    -FirewallRuleName $firewallRuleName -StartIpAddress $startip -EndIpAddress $endip

# Create firewall rule to allow connections from client IP address
New-AzSqlServerFirewallRule -ResourceGroupName $rgName `
    -ServerName $secondarySqlServerName `
    -FirewallRuleName "ClientIPAddress" -StartIpAddress $myip -EndIpAddress $myip

# Create sql database
New-AzSqlDatabase  -ResourceGroupName $rgName `
    -ServerName $sqlServerName `
    -DatabaseName $databaseName `
    -RequestedServiceObjectiveName $sqlEdition `
    -CollationName "JAPANESE_CI_AS" `
    -MaxSizeBytes $sqlSize

# Create failover group
New-AzSqlDatabaseFailoverGroup -ResourceGroupName $rgName `
    -ServerName $sqlServerName `
    -PartnerResourceGroupName $rgName `
    -PartnerServerName $secondarySqlServerName `
    -FailoverGroupName $failoverGroupName `
    -FailoverPolicy Automatic `
    -GracePeriodWithDataLossHours 1 -Verbose

# Add Database to failover group
Get-AzSqlDatabase -ResourceGroupName $rgName -ServerName $sqlServerName -DatabaseName $databaseName | `
    Add-AzSqlDatabaseToFailoverGroup -ResourceGroupName $rgName -ServerName $sqlServerName -FailoverGroupName $failoverGroupName -Verbose

# Show
# Primary
Get-AzSqlServer -ResourceGroupName $rgName -ServerName $sqlServerName
Get-AzSqlServerFirewallRule -ResourceGroupName $rgName -ServerName $sqlServerName
Get-AzSqlDatabase -ResourceGroupName $rgName -ServerName $sqlServerName
# Secondary
Get-AzSqlServer -ResourceGroupName $rgName -ServerName $secondarySqlServerName
Get-AzSqlServerFirewallRule -ResourceGroupName $rgName -ServerName $secondarySqlServerName
Get-AzSqlDatabase -ResourceGroupName $rgName -ServerName $secondarySqlServerName

# Delete
Remove-AzSqlDatabaseFailoverGroup -ResourceGroupName $rgName `
    -ServerName $sqlServerName `
    -FailoverGroupName $failoverGroupName -Verbose

# Secondary
Remove-AzSqlDatabase -ResourceGroupName $rgName -ServerName $secondarySqlServerName -DatabaseName $databaseName
Remove-AzSqlServerFirewallRule $rgName -ServerName $secondarySqlServerName -FirewallRuleName $firewallRuleName
Remove-AzSqlServerFirewallRule $rgName -ServerName $secondarySqlServerName -FirewallRuleName "ClientIPAddress"
Remove-AzSqlServer -ResourceGroupName $rgName -ServerName $secondarySqlServerName

# Primary
Remove-AzSqlDatabase -ResourceGroupName $rgName -ServerName $sqlServerName -DatabaseName $databaseName
Remove-AzSqlServerFirewallRule $rgName -ServerName $sqlServerName -FirewallRuleName $firewallRuleName
Remove-AzSqlServerFirewallRule $rgName -ServerName $sqlServerName -FirewallRuleName "ClientIPAddress"
Remove-AzSqlServer -ResourceGroupName $rgName -ServerName $sqlServerName

# Delete resource gorup
Remove-AzResourceGroup -Name $rgName -Force