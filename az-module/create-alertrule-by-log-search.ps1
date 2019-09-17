$subscriptionId = "a123d7efg-123c-1234-5678-a12bc3defgh4"
$rgName = "e-iaas-rg"
$location = "japan east"
$workspaceName = "e-iaas-workspace"
$ruleName = "HeartbeatMonitoring"
$actionGroupName = "sampleAG"
$query = @'
Heartbeat 
| summarize LastCall = max(TimeGenerated) by Computer 
| where LastCall < ago(5m)
'@

$source = New-AzScheduledQueryRuleSource `
    -Query $query `
    -DataSourceId "/subscriptions/$subscriptionId/resourceGroups/$rgName/providers/microsoft.OperationalInsights/workspaces/$workspaceName"

$schedule = New-AzScheduledQueryRuleSchedule `
    -FrequencyInMinutes 5 `
    -TimeWindowInMinutes 5

# Specify for metric monitoring
# $metricTrigger = New-AzScheduledQueryRuleLogMetricTrigger `
#     -ThresholdOperator "GreaterThan" `
#     -Threshold 2 `
#     -MetricTriggerType "Consecutive" `
#     -MetricColumn "_ResourceId"

$triggerCondition = New-AzScheduledQueryRuleTriggerCondition `
    -ThresholdOperator "GreaterThan" `
    -Threshold 0
    # -MetricTrigger $metricTrigger # Specify for metric monitoring

$aznsActionGroup = New-AzScheduledQueryRuleAznsActionGroup `
    -ActionGroup "/subscriptions/$subscriptionId/resourceGroups/$rgName/providers/microsoft.insights/actiongroups/$actionGroupName" `
    -EmailSubject "Custom email subject"

$alertingAction = New-AzScheduledQueryRuleAlertingAction `
    -AznsAction $aznsActionGroup `
    -Severity "3" `
    -Trigger $triggerCondition
    # -ThrottlingInMinutes 30 # No alert notification time

New-AzScheduledQueryRule `
    -ResourceGroupName $rgName `
    -Location $location `
    -Action $alertingAction `
    -Enabled $true `
    -Description "Heartbeat is not collected for more than 5 minutes." `
    -Schedule $schedule `
    -Source $source `
    -Name $ruleName