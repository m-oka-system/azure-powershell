# リソースグループ
$rg = "AW-RG"
# 仮想マシンの情報
$vmName = "Web01"
# ストレージ
$storageAccountName = "awvmstorageacct"
# カスタムスクリプト ファイルの情報
$container = "scripts"
$scriptFile = "Install-IIS.ps1"

# ストレージ キーを取得
$key = (Get-AzureRmStorageAccountKey -Name $storageAccountName `
      -ResourceGroupName $rg).Key1
# カスタムスクリプトの実行
Set-AzureRmVMCustomScriptExtension -ContainerName $container `
         -FileName $scriptFile -Name $vmName -ResourceGroupName $rg `
         -VMName $vmName -Location $location -Run $scriptFile `
         -StorageAccountKey $key -StorageAccountName $StorageAccountName 