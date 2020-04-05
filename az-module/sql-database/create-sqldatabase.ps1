# Variables

# ResourceGroup
$rgName = "paas-rg"
$location = "Japan East"

# SQLServer
$sqlServerName = "e-paas-sql"
$sqlLogin = "sqladmin"
$sqlPassword = "P@ssword"
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $sqlLogin, $(ConvertTo-SecureString -String $sqlPassword -AsPlainText -Force)
$firewallRuleName = "AllowSome"
$startip = "0.0.0.0"
$endip = "0.0.0.0"
$myip = "input your ip address"

# SQLDatabase
$databaseName = "MyDatabase"
$sqlEdition = "Basic" #"S0"
$sqlSize = 2gb

# Create resource group
New-AzResourceGroup -Name $rgName -Location $location -Verbose -Force

# Create sql server
New-AzSqlServer -ResourceGroupName $rgName -Location $location `
    -ServerName $sqlServerName `
    -SqlAdministratorCredentials $cred

# Create firewall rule to allow connections from Azure services
New-AzSqlServerFirewallRule -ResourceGroupName $rgName `
    -ServerName $sqlServerName `
    -FirewallRuleName $firewallRuleName -StartIpAddress $startip -EndIpAddress $endip

# Create firewall rule to allow connections from client IP address
New-AzSqlServerFirewallRule -ResourceGroupName $rgName `
    -ServerName $sqlServerName `
    -FirewallRuleName "ClientIPAddress" -StartIpAddress $myip -EndIpAddress $myip

# Create sql database
New-AzSqlDatabase  -ResourceGroupName $rgName `
    -ServerName $sqlServerName `
    -DatabaseName $databaseName `
    -RequestedServiceObjectiveName $sqlEdition `
    -CollationName "JAPANESE_CI_AS" `
    -MaxSizeBytes $sqlSize

# Show
Get-AzSqlServer -ResourceGroupName $rgName -ServerName $sqlServerName
Get-AzSqlServerFirewallRule -ResourceGroupName $rgName -ServerName $sqlServerName
Get-AzSqlDatabase -ResourceGroupName $rgName -ServerName $sqlServerName

# Delete
Remove-AzSqlDatabase -ResourceGroupName $rgName -ServerName $sqlServerName -DatabaseName $databaseName
Remove-AzSqlServerFirewallRule $rgName -ServerName $sqlServerName -FirewallRuleName $firewallRuleName
Remove-AzSqlServer -ResourceGroupName $rgName -ServerName $sqlServerName

# Delete resource gorup
Remove-AzResourceGroup -Name $rgName -Force