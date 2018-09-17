# Valiables
$resourceGroupName = "w-arm-rg"
$jobCollectionName = "w-arm-scheduler-1"
$jobName ="Scheduler01"
$storageAccountName = "warmstorageaccount"
$storageQueueName = "queue"
#$sasToken = "Create with AzurePotal and paste here"
$sasToken = "?sv=2014-02-14&sig=W08g%2FclmMlbYN9rF55cGmebWxEH%2B9kvZ0KjDwT6Vq0U%3D&se=2068-11-13T01%3A28%3A08Z&sp=a"

# Create scheduler job
New-AzureRmSchedulerStorageQueueJob -ResourceGroupName $resourceGroupName -JobCollectionName $jobCollectionName `
   -JobName $jobName `
   -StorageQueueAccount $storageAccountName `
   -StorageQueueName $storageQueueName `
   -StorageSASToken $sasToken `
   -StorageQueueMessage "Hello!World." `
   -StartTime "2018/09/10 23:00:00" `
   -Interval 1 `
   -Frequency Day

# Show
Get-AzureRmSchedulerJob -ResourceGroupName $resourceGroupName -JobCollectionName $jobCollectionName

# Delete
Remove-AzureRmSchedulerJob -ResourceGroupName $resourceGroupName -JobCollectionName $jobCollectionName -JobName $jobName

