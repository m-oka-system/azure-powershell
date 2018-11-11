# Variables
$resourceGroupName = "e-automation-rg"
$location = "Japan East"
$automationAccountName = "automation-ps-aa"
$runbookName = "first-runbook-ps"
$runbookPath = "C:\azure\first-runbook-ps.ps1"

# Create resource group
New-AzureRmResourceGroup -Name $resourceGroupName -Location $location -Verbose -Force

# Create runbook
New-AzureRmAutomationRunbook -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -Name $runbookName -Type PowerShell -LogVerbose $true

# Import
Import-AzureRmAutomationRunbook -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -Name $runbookName -Type PowerShell `
    -Path $runbookPath -Force

# Show
Get-AzureRmAutomationRunbook  -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -Name $runbookName

# Delete
Remove-AzureRmAutomationRunbook  -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -Name $runbookName -Force -Verbose

# Publish runbook
Publish-AzureRmAutomationRunbook -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -Name $runbookName

# Start runbook
Start-AzureRmAutomationRunbook -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -Name $runbookName -Verbose