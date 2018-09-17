﻿# リソースグループ
$rg = "AW-RG"
# ストレージ
$storageAccountName = "awvmstorageacct"
$container = "scripts"
# スクリプト ファイル
$scriptFile = "D:\Solutions\Install-IIS-ByDSC.ps1.zip"

# スクリプトのアップロード
$ctx = New-AzureStorageContext -StorageAccountName $storageAccountName `
      -StorageAccountKey (Get-AzureRmStorageAccountKey -Name $storageAccountName `
      -ResourceGroupName $rg).Key1
Set-AzureStorageBlobContent -File $scriptFile `
-Container $container -Context $ctx

# コンテナーのアクセス許可の変更
Get-AzureStorageContainer $container  -Context $ctx | `
Set-AzureStorageContainerAcl -Permission blob -PassThru