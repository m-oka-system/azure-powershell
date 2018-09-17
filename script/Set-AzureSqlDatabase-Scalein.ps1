$SubscriptionId = "ef6xxxxx-xxxx-xxxx-xxxx-bfxxxxxxxxx"
$ServerName     = "k8fxxxxxxx"
$DatabaseName   = "FBRDB"
$Edition        = "Standard"
$Level          = "S1"
 
Select-AzureSubscription -SubscriptionId $SubscriptionId
$ServiceObjective = get-azuresqldatabaseserviceobjective -ServerName $ServerName -ServiceObjectiveName $Level
$ScaleRequest = Set-AzureSqlDatabase -DatabaseName $DatabaseName -ServerName $ServerName -Edition $Edition -ServiceObjective $ServiceObjective -Force
$ScaleRequest