#Retrieve a queue.
$filename1 = "D:\Queue.txt"
$filename2 = "D:\Queue_Trim.txt"
$filename3 = "D:\Queue_Trim_ops.txt"

$datetime = Get-Date -format "yyyy/MM/dd HH:mm"
echo $datetime | Out-File $filename1

$StorageAccountName = "vinxstrage"
$StorageAccountKey = Get-AzureStorageKey -StorageAccountName $StorageAccountName
$Ctx = New-AzureStorageContext –StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey.Primary
#$QueueName = "queuename"

Get-AzureStorageQueue –Context $Ctx -Name "tranlog" | select Name,ApproximateMessageCount | Sort-Object ApproximateMessageCount | Format-Table -AutoSize -HideTableHeaders | Out-File -Append $filename1
Get-AzureStorageQueue –Context $Ctx -Name "taskjobs" | select Name,ApproximateMessageCount | Sort-Object ApproximateMessageCount | Format-Table -AutoSize -HideTableHeaders | Out-File -Append $filename1
Get-AzureStorageQueue –Context $Ctx -Name "taskjobsshadow" | select Name,ApproximateMessageCount | Sort-Object ApproximateMessageCount | Format-Table -AutoSize -HideTableHeaders | Out-File -Append $filename1

(gc $filename1) | ? {$_.trim() -ne "" }| Out-File -Append $filename2
(gc $filename2) | ? {$_.trim() -ne "" }| Out-File $filename3