# Variables
$storageAccountName = "warmstorageaccount"
$storageAccountKey = Get-AzureStorageKey -StorageAccountName $storageAccountName
$ctx = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey.Primary
$containerName = "windows-powershell-dsc"
$vmName = "w-asm-vm-1"
$serviceName = "w-arm-cs"
$vm = Get-AzureVM -ServiceName $serviceName -Name $vmName
$archivefFile = "WindowsWebServer.ps1.zip"
$confName = "IIS"


# Configures the DSC extension on a virtual machine
Set-AzureVMDscExtension -VM $vm -ConfigurationArchive $archivefFile `
    -ConfigurationName $confName `
    -StorageContext $ctx `
    -ContainerName $containerName -Verbose | `
    Update-AzureVM

# Show
Get-AzureVMDscExtension -VM $vm
Get-AzureVMDscExtensionStatus -VM $vm

# Delete
Remove-AzureVMDscExtension -VM $vm