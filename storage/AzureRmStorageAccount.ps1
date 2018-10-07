# Variables
$resourceGroupName = "w-arm-rg"
$location = "Japan West"
$storageAccountType = "Standard_LRS"
$storageAccountName = "warmstorage123"

<# –Type でレプリケーションの種類を指定可
-- Standard_LRS
-- Standard_ZRS
-- Standard_GRS
-- Standard_RAGRS
-- Premium_LRS#>

# Create resource group
New-AzureRmResourceGroup -Name $resourceGroupName -Location $location -Verbose -Force

# Create storage account
New-AzureRmStorageAccount -ResourceGroupName $resourceGroupName -Location $location `
    -Name $storageAccountName `
    -Type $storageAccountType -Verbose

# Show
Get-AzureRmStorageAccount -ResourceGroupName $resourceGroupName -StorageAccountName $storageAccountName

# Delete
Remove-AzureRmStorageAccount -ResourceGroupName $resourceGroupName -StorageAccountName $storageAccountName -Force
