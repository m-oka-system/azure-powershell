# Variables
$storageAccountName = "warmstorageaccount"
$storageAccountKey = Get-AzureStorageKey -StorageAccountName $storageAccountName
$ctx = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey.Primary
$containerName = "windows-powershell-dsc"
$confPath = ".\WindowsWebServer.ps1"
$archivefPath = ".\WindowsWebServer.ps1.zip"

# Archive a DSC script
Publish-AzureVMDscConfiguration -ConfigurationPath $confPath -ConfigurationArchivePath $archivefPath -Force

# Uploads a DSC script to Azure blob storage
Publish-AzureVMDscConfiguration -ConfigurationPath $archivefPath `
    -ContainerName $containerName `
    -StorageContext $ctx
