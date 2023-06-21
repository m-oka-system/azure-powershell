# Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process | Out-Null

# Log in first with Connect-AzAccount if not using Cloud Shell
$azContext = (Connect-AzAccount -Identity).context
$subscriptionId = $azContext.Subscription.Id
$aggregation = @{
    totalCost= @{
        name = "PreTaxCost";
        function = "Sum"
    }
}

# Query the usage data for scope defined.
$response = Invoke-AzCostManagementQuery `
    -Scope "/subscriptions/$subscriptionId" `
    -Timeframe MonthToDate `
    -Type Usage `
    -DatasetGranularity 'None' `
    -DatasetAggregation $aggregation

$totalCost = $response.Row[0][0]

# Invoke the REST API to Line notify
$lineRequestURI = "https://notify-api.line.me/api/notify"
$vaultName = Get-AutomationVariable -Name VAULT_NAME
$lineToken = Get-AzKeyVaultSecret -VaultName $vaultName -name LINE-NOTIFY-ACCESS-TOKEN -AsPlainText
$lineAuthHeader = @{
    'Content-Type'  = 'application/x-www-form-urlencoded'
    'Authorization' = 'Bearer ' + $lineToken
}
$lineRequestbody = @{
    message="`n$totalCost JPY"
}

Invoke-RestMethod -Method POST -Uri $lineRequestURI -Headers $lineAuthHeader -Body $lineRequestbody
