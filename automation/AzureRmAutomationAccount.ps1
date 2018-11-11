# Variables
$resourceGroupName = "e-automation-rg"
$location = "Japan East"
$automationAccountName = "automation-ps-aa"

# Create resource group
New-AzureRmResourceGroup -Name $resourceGroupName -Location $location -Verbose -Force

# Create automation account
New-AzureRmAutomationAccount -ResourceGroupName $resourceGroupName -Location $location -Name $automationAccountName

# Show
Get-AzureRmAutomationAccount -ResourceGroupName $resourceGroupName

# Delete
Remove-AzureRmAutomationAccount -ResourceGroupName $resourceGroupName -Name $automationAccountName -Force -Verbose