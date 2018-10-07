# Variables
$resourceGroupName = "w-arm-rg"
$location = "Japan West"
$jobCollectionName = "w-arm-scheduler-1"

# Create scheduler job collection
New-AzureRmSchedulerJobCollection -ResourceGroupName $resourceGroupName -Location $location `
    -JobCollectionName $schedulerName `
    -Plan Free

# Show
Get-AzureRmSchedulerJobCollection -ResourceGroupName $resourceGroupName -JobCollectionName $jobCollectionName

# Delete
Remove-AzureRmSchedulerJobCollection -ResourceGroupName $resourceGroupName -JobCollectionName $schedulerName