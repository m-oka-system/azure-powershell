$SubscriptionName = "MSDN Platforms"
Login-AzureRmAccount
Get-AzureRmSubscription
Get-AzureRmSubscription –SubscriptionName $SubscriptionName `
| Select-AzureRmSubscription