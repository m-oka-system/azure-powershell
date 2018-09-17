# Valiables

# ResourceGroup
$resourceGroupName = "w-arm-rg"
$location = "Japan West"

# SQLServer
$sqlServerName = "w-arm-sql"
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

# Create resource group
New-AzureRmResourceGroup -Name $resourceGroupName -Location $location -Verbose -Force

# Create sql server
New-AzureRmSqlServer -ResourceGroupName $resourceGroupName -Location $location `
    -ServerName $sqlServerName `
    -SqlAdministratorCredentials $cred

# Create firewall rule
New-AzureRmSqlServerFirewallRule -ResourceGroupName $resourceGroupName `
    -ServerName $sqlServerName `
    -FirewallRuleName $firewallRuleName -StartIpAddress $startip -EndIpAddress $endip

# Create sql database
New-AzureRmSqlDatabase  -ResourceGroupName $resourceGroupName `
    -ServerName $sqlServerName `
    -DatabaseName $databaseName `
    -RequestedServiceObjectiveName $sqlEdition `
    -CollationName "JAPANESE_CI_AS" `
    -MaxSizeBytes $sqlSize

# Show
Get-AzureRmSqlServer -ResourceGroupName $resourceGroupName -ServerName $sqlServerName
Get-AzureRmSqlServerFirewallRule -ResourceGroupName $resourceGroupName -ServerName $sqlServerName
Get-AzureRmSqlDatabase -ResourceGroupName $resourceGroupName -ServerName $sqlServerName

# Delete
Remove-AzureRmSqlDatabase -ResourceGroupName $resourceGroupName -ServerName $sqlServerName -DatabaseName $databaseName
Remove-AzureRmSqlServerFirewallRule $resourceGroupName -ServerName $sqlServerName -FirewallRuleName $firewallRuleName
Remove-AzureRmSqlServer -ResourceGroupName $resourceGroupName -ServerName $sqlServerName
