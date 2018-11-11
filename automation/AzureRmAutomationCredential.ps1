# Variables
$resourceGroupName = "e-automation-rg"
$location = "Japan East"
$automationAccountName = "automation-ps-aa"
$credName = "login-creds"
$userName = "yourusername"
$password = "yourpassword"
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $userName, $(ConvertTo-SecureString -String $password -AsPlainText -Force)

# Create resource group
New-AzureRmResourceGroup -Name $resourceGroupName -Location $location -Verbose -Force

# Create variables
New-AzureRmAutomationCredential -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -Name $credName -Value $cred

# Show
Get-AzureRmAutomationCredential -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -Name $credName

# Update
Set-AzureRmAutomationCredential -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -Name $credName -Value $cred

# Delete
Remove-AzureRmAutomationCredential -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -Name $credName -Verbose