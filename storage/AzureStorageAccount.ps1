# Variables
$storageAccountName = "wasmgrs"
$location = "Japan West"
$type = "Standard_LRS"

# Create Storage Account Classic (Resource group can not be specified)
New-AzureStorageAccount `
    -StorageAccountName $storageAccountName `
    -Location $location `
    -Type $type

<# –Type でレプリケーションの種類を指定可
-- Standard_LRS
-- Standard_ZRS
-- Standard_GRS
-- Standard_RAGRS
-- Premium_LRS#>

# Show
Get-AzureStorageAccount -StorageAccountName $storageAccountName

# Change the replication type
Set-AzureStorageAccount -StorageAccountName $storageAccountName -Type Standard_GRS
Set-AzureStorageAccount -StorageAccountName $storageAccountName -Type Standard_LRS

# Delete
Remove-AzureStorageAccount -StorageAccountName $storageAccountName
