# Variables
$csName = "w-arm-cs"
$location = "Japan west"

# Create cloud service
New-AzureService -ServiceName $csName -Location $location

# Show
Get-AzureService -ServiceName $csName

# Delete
Remove-AzureService -ServiceName $csName