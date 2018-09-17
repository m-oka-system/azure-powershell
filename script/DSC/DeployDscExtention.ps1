$resourceGroup = '<resourceGroup>'
$location = 'japanwest'
$vmName = '<vmName>'
$storageName = '<storageName>'

Publish-AzureRmVMDscConfiguration -ConfigurationPath .\DSC\WindowsWebServer.ps1 `
-ResourceGroupName $resourceGroup `
-StorageAccountName $storageName -force

Set-AzureRmVmDscExtension -Version 2.21 `
-ResourceGroupName $resourceGroup `
-VMName $vmName `
-ArchiveStorageAccountName $storageName `
-ArchiveBlobName WindowsWebServer.ps1.zip `
-AutoUpdate:$true `
-ConfigurationName IIS `
-WmfVersion 4.0