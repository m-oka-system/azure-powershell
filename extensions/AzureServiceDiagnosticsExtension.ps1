# Variables
$serviceName = "w-asm-cs"
[System.Xml.XmlDocument] $xmlConfig = New-Object System.Xml.XmlDocument
$XmlConfig.load('C:\azure\configuration\PaaSDiagnostics.PubConfig.xml')
$StorageAccountName = "warmstorageaccount"
$StorageAccountKey = Get-AzureStorageKey -StorageAccountName $StorageAccountName
$Ctx = New-AzureStorageContext –StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey.Primary

# Enable AntimalwareExtension
# $diagconfig  = New-AzureServiceDiagnosticsExtensionConfig -DiagnosticsConfigurationPath $xmlConfig

Set-AzureServiceDiagnosticsExtension -ServiceName $serviceName `
    -StorageContext $Ctx `
    -DiagnosticsConfigurationPath $XmlConfig

Set-AzureServiceDiagnosticsExtension -ServiceName $serviceName -Slot Production -Role ContosoAdsWeb -StorageContext $Ctx `
    -DiagnosticsConfigurationPath C:\azure\configuration\PaaSDiagnostics.ContosoAdsWeb.PubConfig.xml

# Show
Get-AzureServiceDiagnosticsExtension -ServiceName $serviceName

# Delete
Remove-AzureServiceDiagnosticsExtension -ServiceName $serviceName