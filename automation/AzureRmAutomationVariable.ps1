# Variables
$resourceGroupName = "e-automation-rg"
$location = "Japan East"
$automationAccountName = "automation-ps-aa"
$variableName = "log-age"

# Create resource group
New-AzureRmResourceGroup -Name $resourceGroupName -Location $location -Verbose -Force

# Create variables
New-AzureRmAutomationVariable -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -Name $variableName -Encrypted $false -Value 2

# Show
Get-AzureRmAutomationVariable -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -Name $variableName

# Update
Set-AzureRmAutomationVariable -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -Name $variableName -Encrypted $false -Value 3

# Delete
Remove-AzureRmAutomationVariable -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -Name $variableName -Verbose