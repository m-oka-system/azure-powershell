# Valiables
$resourceGroupName = "w-arm-rg"
$location = "Japan West"
$pip = "w-arm-pip"

# Create public ip address 
New-AzureRmPublicIpAddress -ResourceGroupName $resourceGroupName -Location $location `
    -Name $pip `
    -AllocationMethod Dynamic

# Show
Get-AzureRmPublicIpAddress -ResourceGroupName $resourceGroupName -Name $pip

# Delete
Remove-AzureRmPublicIpAddress -ResourceGroupName $resourceGroupName -Name $pip -Force
