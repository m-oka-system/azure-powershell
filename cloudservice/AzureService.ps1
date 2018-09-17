# Valiables
$location = "Japan West"
$serviceName = "w-arm-cs"

# Create coud service (resource group can not be specified)
New-AzureService -ServiceName $serviceName -Location $location -Verbose

# Show
Get-AzureService -ServiceName $serviceName

# Delete
Remove-AzureService -ServiceName $serviceName -Force
