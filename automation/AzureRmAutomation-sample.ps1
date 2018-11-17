# Variables
$resourceGroupName = "e-automation-rg"
$location = "Japan East"
$automationAccountName = "automation-ps-aa"
$runbookName = "first-runbook-ps"
$runbookPath = "C:\azure\first-runbook-ps.ps1"
$variableName = "log-age"
$credName = "login-creds"
$userName = "yourusername"
$password = "yourpassword"
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $userName, $(ConvertTo-SecureString -String $password -AsPlainText -Force)

# Create resource group
New-AzureRmResourceGroup -Name $resourceGroupName -Location $location -Verbose -Force

# Create automation account
New-AzureRmAutomationAccount -ResourceGroupName $resourceGroupName -Location $location -Name $automationAccountName -Verbose

# Import
Import-AzureRmAutomationRunbook -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -Name $runbookName -Type PowerShell `
    -Path $runbookPath -Force -Verbose

# Create credential
New-AzureRmAutomationCredential -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -Name $credName -Value $cred

# Create variables
New-AzureRmAutomationVariable -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -Name $variableName -Encrypted $false -Value 2

# Publish runbook
Publish-AzureRmAutomationRunbook -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -Name $runbookName

# Start runbook
Start-AzureRmAutomationRunbook -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -Name $runbookName

# Clean up
Remove-AzureRmResourceGroup -Name $resourceGroupName -Force -Verbose