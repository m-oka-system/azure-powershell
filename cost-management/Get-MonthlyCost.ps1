# Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process | Out-Null

# Log in first with Connect-AzAccount if not using Cloud Shell
$azContext = (Connect-AzAccount -Identity).context
$subscriptionId = $azContext.Subscription.Id
$aggregation = @{
    totalCost = @{
        name     = "PreTaxCost";
        function = "Sum"
    }
}

# Query the usage data for scope defined.
$retryCount = 0
$retryMax = 5
$totalCost = $null

do {
    $response = Invoke-AzCostManagementQuery `
        -Scope "/subscriptions/$subscriptionId" `
        -Timeframe MonthToDate `
        -Type Usage `
        -DatasetGranularity 'None' `
        -DatasetAggregation $aggregation

    if ($response -eq $null) {
        Write-Output "Retry: $retryCount, response is null. Trying again in 60 seconds..."
        Start-Sleep -Seconds 60
        $retryCount++
        continue
    }

} while ($response -eq $null -and $retryCount -lt $retryMax)

$totalCost = $response.Row[0][0]

if ($totalCost -ne $null) {
    Write-Output $totalCost
}
else {
    Write-Output "Failed to retrieve total cost after $retryMax attempts."
}

# Invoke the REST API to Line notify
$lineRequestURI = "https://notify-api.line.me/api/notify"
$vaultName = Get-AutomationVariable -Name VAULT_NAME
$lineToken = Get-AzKeyVaultSecret -VaultName $vaultName -name LINE-NOTIFY-ACCESS-TOKEN -AsPlainText
$lineAuthHeader = @{
    'Content-Type'  = 'application/x-www-form-urlencoded'
    'Authorization' = 'Bearer ' + $lineToken
}
$lineRequestbody = @{
    message = "`n$totalCost JPY"
}

Invoke-RestMethod -Method POST -Uri $lineRequestURI -Headers $lineAuthHeader -Body $lineRequestbody
