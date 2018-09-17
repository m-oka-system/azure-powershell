$LogDir = "C:\"
$EventLog = Get-WmiObject win32_nteventlogfile
foreach ($Log in $EventLog){
    $Log.PSBase.Scope.Options.EnablePrivileges = $true
    $EvtFile = $Log.LogfileName + "_" + (Get-Date).ToString("yyyyMMddHHmm") + ".evt"
    if((Test-Path ($LogDir + "" + $EvtFile)) -eq $true) {
        Remove-Item ($LogDir + "" + $EvtFile)
    }
    $Log.backupeventlog($LogDir + "" + $EvtFile)
}