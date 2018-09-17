# リソースグループ
$rg = "AW-RG"
# ストレージ
$storageAccountName = "awvmstorageacct"
$container = "scripts"
# スクリプト ファイル
$scriptFile = "D:\Solutions\Install-IIS.ps1"

# スクリプトのアップロード
$ctx = New-AzureStorageContext -StorageAccountName $storageAccountName `
      -StorageAccountKey (Get-AzureRmStorageAccountKey -Name $storageAccountName `
      -ResourceGroupName $rg).Key1
New-AzureStorageContainer -Name $container -Permission Off -Context $ctx
Set-AzureStorageBlobContent -File $scriptFile `
-Container $container -Context $ctx