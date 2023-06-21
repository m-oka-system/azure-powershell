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
$retryCount = 0
$retryMax = 3
$totalCost = $null

do {
    $response = Invoke-AzCostManagementQuery `
        -Scope "/subscriptions/$subscriptionId" `
        -Timeframe MonthToDate `
        -Type Usage `
        -DatasetGranularity 'None' `
        -DatasetAggregation $aggregation

    $totalCost = $response.Row[0][0]
    $retryCount++

    if($totalCost -eq $null) {
        Write-Host "Retry: $retryCount, total cost not retrieved. Trying again in 5 seconds..."
        Start-Sleep -Seconds 5
    }
} while($totalCost -eq $null -and $retryCount -lt $retryMax)

if($totalCost -ne $null) {
    Write-Host $totalCost
} else {
    Write-Host "Failed to retrieve total cost after $retryMax attempts."
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
    message="`n$totalCost JPY"
}

Invoke-RestMethod -Method POST -Uri $lineRequestURI -Headers $lineAuthHeader -Body $lineRequestbody
