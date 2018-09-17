# Valiables
$resourceGroupName = "w-arm-rg"
$location = "Japan West"
$avlSetName = "w-arm-avl"

# Create availabilityset
New-AzureRmAvailabilitySet -ResourceGroupName $resourceGroupName -Location $location `
    -Name $avlSetName `
    -Sku aligned `
    -PlatformFaultDomainCount 2 `
    -PlatformUpdateDomainCount 2

# Show
Get-AzureRmAvailabilitySet -ResourceGroupName $resourceGroupName -Name $avlSetName

# Delete
Remove-AzureRmAvailabilitySet -ResourceGroupName $resourceGroupName -Name $avlSetName -Force