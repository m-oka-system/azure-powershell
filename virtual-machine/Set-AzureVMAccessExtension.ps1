# Valiables
$serviceName = "w-arm-cs"
$vmName = "w-arm-vm01"
$userName = "cloudadmin"
$password = "InputYourPassword"

# Reset password
Get-AzureVM -ServiceName $serviceName -Name $vmName | `
    Set-AzureVMAccessExtension -UserName $userName -Password $password | `
    Update-AzureVM