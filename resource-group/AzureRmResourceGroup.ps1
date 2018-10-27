# Variables
$resourceGroupName = "e-arm-rg"
$location = "Japan West"

# Create resource group
New-AzureRmResourceGroup -Name $resourceGroupName -Location $location -Verbose -Force

# Show
Get-AzureRmResourceGroup -Name $resourceGroupName

# Delete
Remove-AzureRmResourceGroup -Name $resourceGroupName -Force