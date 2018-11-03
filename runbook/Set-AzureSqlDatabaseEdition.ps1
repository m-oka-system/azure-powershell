workflow Set-AzureSqlDatabaseEdition 
{ 
    param 
    ( 
        # Name of the Azure SQL Database server (Ex: bzb98er9bp) 
        [parameter(Mandatory=$true)]  
        [string] $SqlServerName, 
 
        # Target Azure SQL Database name  
        [parameter(Mandatory=$true)]  
        [string] $DatabaseName, 
 
        # Desired Azure SQL Database edition {Basic, Standard, Premium} 
        [parameter(Mandatory=$true)]  
        [string] $Edition, 
 
        # Desired performance level {Basic, S0, S1, S2, P1, P2, P3} 
        [parameter(Mandatory=$true)]  
        [string] $PerfLevel, 
 
        # Credentials for $SqlServerName stored as an Azure Automation credential asset 
        # When using in the Azure Automation UI, please enter the name of the credential asset for the "Credential" parameter 
        [parameter(Mandatory=$true)]  
        [PSCredential] $Credential 
    ) 
     
    inlinescript 
    { 
        Write-Output "Begin vertical scaling script..." 
        
        # Establish credentials for Azure SQL Database server  
        $Servercredential = new-object System.Management.Automation.PSCredential($Using:Credential.UserName, (($Using:Credential).GetNetworkCredential().Password | ConvertTo-SecureString -asPlainText -Force))  
         
        # Create connection context for Azure SQL Database server 
        $CTX = New-AzureSqlDatabaseServerContext -ManageUrl “https://$Using:SqlServerName.database.windows.net” -Credential $ServerCredential 
         
        # Get Azure SQL Database context 
        $Db = Get-AzureSqlDatabase $CTX –DatabaseName $Using:DatabaseName 
         
        # Specify the specific performance level for the target $DatabaseName 
        $ServiceObjective = Get-AzureSqlDatabaseServiceObjective $CTX -ServiceObjectiveName "$Using:PerfLevel" 
         
        # Set the new edition/performance level 
        Set-AzureSqlDatabase $CTX –Database $Db –ServiceObjective $ServiceObjective –Edition $Using:Edition -Force 
         
        # Output final status message 
        Write-Output "Scaled the performance level of $Using:DatabaseName to $Using:Edition - $Using:PerfLevel" 
        Write-Output "Completed vertical scale" 
    } 
}