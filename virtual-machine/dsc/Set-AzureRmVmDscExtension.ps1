# Variables
$resourceGroupName = "w-arm-rg"
$vmName = "w-arm-vm-1"
$storageAccountName = "warmstorageaccount"

# Configures the DSC extension on a virtual machine
Set-AzureRmVmDscExtension -Version 2.21 `
    -ResourceGroupName $resourceGroupName `
    -VMName $vmName `
    -ArchiveStorageAccountName $storageAccountName `
    -ArchiveBlobName WindowsWebServer.ps1.zip `
    -AutoUpdate:$true `
    -ConfigurationName IIS `
    -WmfVersion 4.0