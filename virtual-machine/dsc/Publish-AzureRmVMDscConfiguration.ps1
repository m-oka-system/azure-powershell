# Valiables
$resourceGroupName = "w-arm-rg"
$storageAccountName = "warmstorageaccount"

# Uploads a DSC script to Azure blob storage
Publish-AzureRmVMDscConfiguration -ConfigurationPath .\WindowsWebServer.ps1 `
    -ResourceGroupName $resourceGroupName `
    -StorageAccountName $storageAccountName -force
