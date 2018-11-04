# Install AzureRmStorageTable module
Install-Module AzureRmStorageTable

$storageAccountName = "warmstorageaccount"
$storageAccountKey = Get-AzureStorageKey -storageAccountName $storageAccountName
$ctx = New-AzureStorageContext -storageAccountName $storageAccountName -storageAccountKey $storageAccountKey.Primary
$tableName = "WADLogsTable"
$storageTable = Get-AzureStorageTable –Name $tableName –Context $ctx
$datetime = Get-Date -Format "yyyyMMddHHmmss"
$dirName = "C:\azure\"
$fileName = $tablename + "_" + $datetime + ".txt"
$filePath = $dirName + $fileName

# Show table list
Get-AzureStorageTable –Context $ctx | select Name

# Show all records
Get-AzureStorageTableRowAll -table $storageTable | ft | Out-File $filePath


# Using custom filters
Get-AzureStorageTableRowByCustomFilter -table $storageTable `
    -customFilter "(Level eq '4')" | ft

# Specific values of a particular column
Get-AzureStorageTableRowByColumnName -table $storageTable `
    -columnName "Level" `
    -value "4" `
    -operator Equal

# Export csv
[DateTime]$localStartTime = "2018/11/04 13:00:00"
[DateTime]$localEndTime = "2018/11/04 14:00:00"
[DateTime]$searchStartTime = $localStartTime.ToUniversalTime() #convert time to utc
[DateTime]$searchEndTime = $localEndTime.ToUniversalTime()     #convert time to utc

Get-AzureStorageTableRowAll -table $storageTable |
    Where-Object {($_.Level -eq 4) -and ($_.Timestamp -gt $searchStartTime) -and ($_.Timestamp -lt $searchEndTime)} |
    Select-Object Timestamp, Role, RoleInstance, Level,Message |
    Export-Csv -path $filePath -Encoding Default -NoTypeInformation
    #-Delimiter `t
