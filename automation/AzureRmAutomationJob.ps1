# Variables
$resourceGroupName = "e-automation-rg"
$location = "Japan East"
$automationAccountName = "automation-ps-aa"
$runbookName = "first-runbook-ps"

# Show jobs history
$latestJob = Get-AzureRmAutomationJob -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -RunbookName $runbookName |
    Sort-Object -Descending | Select-Object -First 1 | Get-AzureRmAutomationJobOutput

# Show output of jobs
$latestJob | Get-AzureRmAutomationJobOutput

# Show full output of job output record
$latestJob | Get-AzureRmAutomationJobOutput | Get-AzureRmAutomationJobOutputRecord