# Variables
$fileName = "ServiceConfiguration.Cloud.cscfg"
$StorageAccountName = "warmstorageaccount"
$StorageAccountKey = Get-AzureStorageKey -StorageAccountName $StorageAccountName
$Ctx = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey.Primary
$containerName = "deploy"

# Download blob to local disk
Get-AzureStorageBlobContent -Blob $fileName -Container $containerName -Destination ".\" -Context $ctx
