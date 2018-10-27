# Variables
$cspkgFile = "ContosoAdsCloudService.cspkg"
$cscfgFile = "ServiceConfiguration.Cloud.cscfg"
$StorageAccountName = "warmstorageaccount"
$StorageAccountKey = Get-AzureStorageKey -StorageAccountName $StorageAccountName
$Ctx = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey.Primary
$containerName = "deploy"
$serviceName = "w-arm-cs"

# Create blob container
New-AzureStorageContainer -Context $Ctx -Container $containerName

# Upload pakcage file and config file to blob container
$cspkg = Set-AzureStorageBlobContent -Context $Ctx -Container $containerName -File $cspkgFile
$cscfg = Set-AzureStorageBlobContent -Context $Ctx -Container $containerName -File $cscfgFile

# Create new deployment
$pakcageUri = $cspkg.ICloudBlob.Uri.AbsoluteUri
New-AzureDeployment -ServiceName $serviceName -Slot Staging -Package $pakcageUri -Configuration $cscfgFile -Verbose

# Download blob to local disk
# Get-AzureStorageBlobContent -Blob $cscfgFile -Container $containerName -Destination ".\" -Context $ctx

# Check the state of the instance
$deployment = Get-AzureDeployment -ServiceName $serviceName -Slot Staging
$deployment.RoleInstanceList.InstanceStatus

# Swaps the deployments in production and staging
Move-AzureDeployment -ServiceName $serviceName -Verbose

# Delete deployment
Remove-AzureDeployment -ServiceName $serviceName -Slot Staging -Verbose -Force
Remove-AzureDeployment -ServiceName $serviceName -Slot Production -Verbose -Force