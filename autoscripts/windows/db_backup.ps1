# Script to back up PostgreSQL database
$DBName = "testdb_win" # Use the Windows DB name
$DBUser = "testuser_win" # Use the Windows DB user
$DBPass = "Lotidrosaparole#6" # <<< USE THE CORRECT PASSWORD
$BackupDir = "C:\Backup"
$TimeStamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
$BackupFileName = "postgres_backup_${DBName}_${TimeStamp}.sql" # Temp file
$BackupFileFullPath = Join-Path $BackupDir $BackupFileName
$ZipFileName = "postgres_backup_${DBName}_${TimeStamp}.zip" # Final zip file
$ZipFileFullPath = Join-Path $BackupDir $ZipFileName
$LogFile = "C:\Automation\Logs\db_backup.log"
$pgBinPath = "C:\Program Files\PostgreSQL\14\bin" # <<< Adjust PG Version/Path if needed
$pgDumpExe = Join-Path $pgBinPath "pg_dump.exe"

if (-not (Test-Path $BackupDir -PathType Container)) { New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null }
if (-not (Test-Path (Split-Path $LogFile) -PathType Container)) { New-Item -ItemType Directory -Path (Split-Path $LogFile) -Force | Out-Null }
Function LogWrite { param($Message) Add-Content -Path $LogFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message" }

LogWrite "Starting PostgreSQL backup for database '$DBName' to '$ZipFileFullPath'"

if (-not (Test-Path $pgDumpExe -PathType Leaf)) { LogWrite "ERROR: pg_dump.exe not found at '$pgDumpExe'."; exit 1 }

$env:PGPASSWORD = $DBPass # Set env variable for pg_dump

try {
    LogWrite "Running pg_dump to $BackupFileFullPath..."
    # Use Start-Process to capture stderr, check exit code
    $process = Start-Process -FilePath $pgDumpExe -ArgumentList "-U $DBUser -h localhost -Fc -f `"$BackupFileFullPath`" $DBName" -Wait -PassThru -NoNewWindow -RedirectStandardError "$($BackupFileFullPath).err"

    if ($process.ExitCode -ne 0) {
        $stderr = Get-Content "$($BackupFileFullPath).err" -Raw -ErrorAction SilentlyContinue
        Remove-Item "$($BackupFileFullPath).err" -Force -ErrorAction SilentlyContinue
        throw "pg_dump failed with exit code $($process.ExitCode). Stderr: $stderr"
    }
    Remove-Item "$($BackupFileFullPath).err" -Force -ErrorAction SilentlyContinue # Remove empty error file on success
    LogWrite "pg_dump completed successfully to $BackupFileFullPath"

    LogWrite "Compressing backup file to $ZipFileFullPath..."
    Compress-Archive -Path $BackupFileFullPath -DestinationPath $ZipFileFullPath -Force -ErrorAction Stop
    LogWrite "Compression successful."

    # Remove the uncompressed .sql file
    Remove-Item -Path $BackupFileFullPath -Force
    LogWrite "Removed uncompressed file: $BackupFileFullPath"

    Get-Item $ZipFileFullPath | Select-Object Name, Length | Format-Table -AutoSize | Out-String | Add-Content -Path $LogFile

} catch {
    LogWrite "ERROR: Database backup failed! $($_.Exception.Message)"
    # Clean up partial files
    if (Test-Path $BackupFileFullPath -PathType Leaf) { Remove-Item -Path $BackupFileFullPath -Force }
    if (Test-Path $ZipFileFullPath -PathType Leaf) { Remove-Item -Path $ZipFileFullPath -Force }
    exit 1
} finally {
    Remove-Item env:PGPASSWORD -ErrorAction SilentlyContinue # Clean up env var
}
LogWrite "Database backup script finished."
exit 0
