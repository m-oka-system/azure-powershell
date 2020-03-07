Install-Module -Name Az -AllowClobber -Scope CurrentUser
Get-Module | where {$_.Name -like "Az*"} | select Name, Version