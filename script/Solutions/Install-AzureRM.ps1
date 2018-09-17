Get-Module
Get-ExecutionPolicy
Set-ExecutionPolicy RemoteSigned
Install-Module AzureRM -RequiredVersion 1.0.1
Install-AzureRM
Import-Module AzureRM 
Get-Module | ft name,version
Get-Help AzureRM