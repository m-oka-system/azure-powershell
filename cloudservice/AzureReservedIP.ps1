# PowerShell を使用して予約済み IP アドレスを作成する場合、予約済み IP を作成するリソース グループを指定することはできません。
# Azure では、予約済み IP は Default-Networking という名前のリソース グループに自動的に配置されます。
# Default-Networking 以外のリソース グループに予約済み IP を作成した場合、Get-AzureReservedIP や Remove-AzureReservedIP などのコマンドでその予約済み IP を参照するときに、
# Group resource-group-name reserved-ip-name という名前を参照する必要があります。

# Valiables
$location = "Japan West"
$ipName = "w-arm-ip"
$serviceName = "w-arm-cs"

# Create reserved ip address
New-AzureReservedIP –ReservedIPName $ipName –Location $location

# Assign reserved ip address to cloud service
New-AzureReservedIP –ReservedIPName $ipName –Location $location -ServiceName $serviceName

# Show
Get-AzureReservedIP

# Delete
Remove-AzureReservedIP –ReservedIPName $ipName -Force