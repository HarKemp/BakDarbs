# Script to clean up old log files
$TargetDir = "C:\Automation\Logs"
$DaysToKeep = 7
$CutoffDate = (Get-Date).AddDays(-$DaysToKeep)
$LogFile = "C:\Automation\Logs\cleanup.log" 

if (-not (Test-Path (Split-Path $LogFile) -PathType Container)) { New-Item -ItemType Directory -Path (Split-Path $LogFile) -Force | Out-Null }
$LogMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Starting cleanup of logs older than $CutoffDate in '$TargetDir'."
Add-Content -Path $LogFile -Value $LogMessage

try {
    # Exclude the cleanup log itself from deletion
    Get-ChildItem -Path $TargetDir -Filter *.log -Recurse | Where-Object { !$_.PSIsContainer -and $_.LastWriteTime -lt $CutoffDate -and $_.Name -ne 'cleanup.log' } | ForEach-Object {
        $FilePath = $_.FullName
        $LogMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Deleting: $FilePath (LastWrite: $($_.LastWriteTime))"
        Add-Content -Path $LogFile -Value $LogMessage
        Remove-Item -Path $FilePath -Force -ErrorAction Stop
    }
    $LogMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Log cleanup finished."
    Add-Content -Path $LogFile -Value $LogMessage
} catch {
    $LogMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - ERROR: Log cleanup failed! $($_.Exception.Message)"
    Add-Content -Path $LogFile -Value $LogMessage
    exit 1
}
exit 0
