# Script to back up web server directory
$SourceDir = "C:\inetpub\wwwroot"
$DestDir = "C:\Backup"
$TimeStamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
$ArchiveName = "web_backup_$TimeStamp.zip"
$DestFile = Join-Path $DestDir $ArchiveName
$LogFile = "C:\Automation\Logs\backup.log"

# Ensure directories exist
if (-not (Test-Path $DestDir -PathType Container)) { New-Item -ItemType Directory -Path $DestDir -Force | Out-Null }
if (-not (Test-Path (Split-Path $LogFile) -PathType Container)) { New-Item -ItemType Directory -Path (Split-Path $LogFile) -Force | Out-Null }

$LogMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Starting backup of '$SourceDir' to '$DestFile'"
Add-Content -Path $LogFile -Value $LogMessage

try {
    if (Test-Path $SourceDir -PathType Container) {
        Compress-Archive -Path "$SourceDir\*" -DestinationPath $DestFile -Force -ErrorAction Stop
        $LogMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Backup successful: $DestFile"
        Add-Content -Path $LogFile -Value $LogMessage
        Get-Item $DestFile | Select-Object Name, Length | Format-Table -AutoSize | Out-String | Add-Content -Path $LogFile
    } else {
        $LogMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - ERROR: Source directory '$SourceDir' not found!"
        Add-Content -Path $LogFile -Value $LogMessage
        throw "Source directory not found."
    }
} catch {
    $LogMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - ERROR: Backup failed! $($_.Exception.Message)"
    Add-Content -Path $LogFile -Value $LogMessage
    exit 1 
}
$LogMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Backup script finished."
Add-Content -Path $LogFile -Value $LogMessage
exit 0
