# Variables
# Source storage account
$srcStorageAccountName = "warmstorageaccount"
$srcStorageAccountKey = Get-AzureStorageKey -StorageAccountName $srcStorageAccountName
$srcCtx = New-AzureStorageContext -StorageAccountName $srcStorageAccountName -StorageAccountKey $srcStorageAccountKey.Primary
$srcContainer = "vhds"
$srcBlob = "w-asm-vm-1-os-5019.vhd"
#Destination storage account
$dstStorageAccountName = "easmlrs"
$dstStorageAccountKey = Get-AzureStorageKey -StorageAccountName $dstStorageAccountName
$dstCtx = New-AzureStorageContext -StorageAccountName $dstStorageAccountName -StorageAccountKey $dstStorageAccountKey.Primary
$dstContainer = "vhds"
$dstBlob = "win2012r2.vhd"

# Blob copy
Start-AzureStorageBlobCopy `
    -Context $srcCtx -SrcContainer $srcContainer -SrcBlob $srcBlob `
    -DestContext $dstCtx -DestContainer $dstContainer -DestBlob $dstBlob -Verbose

# Copy status monitoring
Write-Host (Get-Date) ": Copy Started"
do{
    Start-Sleep -Seconds 5
    $copyStatus = Get-AzureStorageBlobCopyState -Context $dstCtx -Container $dstContainer -Blob $dstBlob
    $percent = $copyStatus.BytesCopied / $copyStatus.TotalBytes * 100
    Write-Progress -Activity "Working..." -PercentComplete $percent -CurrentOperation "$percent% complete" -Status "Please wait."
}while($copyStatus.Status -eq "Pending")
Write-Host (Get-Date) ": Copy Completed"
$copyStatus