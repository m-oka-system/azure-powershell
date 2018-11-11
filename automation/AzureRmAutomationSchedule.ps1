# Variables
$resourceGroupName = "e-automation-rg"
$location = "Japan East"
$automationAccountName = "automation-ps-aa"
$runbookName = "first-runbook-ps"
$scheduleName = "Schedule01"
$startTime = (Get-Date "9:00:00").AddDays(1)
[System.DayOfWeek[]]$weekDays = @([System.DayOfWeek]::Monday..[System.DayOfWeek]::Friday)
$timeZone = "Asia/Tokyo"

# Create resource group
New-AzureRmResourceGroup -Name $resourceGroupName -Location $location -Verbose -Force

# Create runbook
New-AzureRmAutomationSchedule -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -Name $scheduleName `
    -StartTime $startTime `
    -WeekInterval 1 `
    -DaysOfWeek $weekDays `
    -TimeZone $timeZone

# Associates runbook to schedule
Register-AzureRmAutomationScheduledRunbook -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName `
    -RunbookName $runbookName `
    -ScheduleName $scheduleName

# Remove association
Unregister-AzureRmAutomationScheduledRunbook -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName `
    -RunbookName $runbookName `
    -ScheduleName $scheduleName -Force -Verbose

# Show
Get-AzureRmAutomationSchedule  -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -Name $scheduleName
Get-AzureRmAutomationScheduledRunbook -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -Name $runbookName


# Delete
Remove-AzureRmAutomationSchedule  -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -Name $scheduleName -Force -Verbose
