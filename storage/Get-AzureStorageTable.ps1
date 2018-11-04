# Install AzureRmStorageTable module
Install-Module AzureRmStorageTable

$storageAccountName = "yourstorageaccount"
$storageAccountKey = Get-AzureStorageKey -storageAccountName $storageAccountName
$ctx = New-AzureStorageContext -storageAccountName $storageAccountName -storageAccountKey $storageAccountKey.Primary
$tableName = "`$MetricsHourPrimaryTransactionsBlob"
$storageTable = Get-AzureStorageTable –Name $tableName –Context $ctx
$datetime = Get-Date -Format "yyyyMMddHHmmss"
$dirName = "C:\azure\"
$fileName = $tablename + "_" + $datetime + ".txt"
$filePath = $dirName + $fileName

# Show table list
Get-AzureStorageTable –Context $ctx | select Name

# Show all records
Get-AzureStorageTableRowAll -table $storageTable | ft | Out-File C:\azure\table.csv


# Using custom filters
Get-AzureStorageTableRowByCustomFilter -table $storageTable `
    -customFilter "(TableTimestamp eq (Get-Date))" | ft

# Specific values of a particular column
Get-AzureStorageTableRowByColumnName -table $storageTable `
    -columnName "TableTimestamp" `
    -value "2018/11/04 10:30:18 +09:00" `
    -operator Equal

# Export csv
Get-AzureStorageTableRowAll -table $storageTable |
    Select-Object TalbeTImeStamp, Avairability,AnonymousAuthorizationError |
    Export-Csv -path $filePath -Encoding Default -NoTypeInformation -Delimiter `t
