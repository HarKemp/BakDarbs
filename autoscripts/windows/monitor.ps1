# Script to monitor system resources
$LogFile = "C:\Automation\Logs\system_health.log"
if (-not (Test-Path (Split-Path $LogFile) -PathType Container)) { New-Item -ItemType Directory -Path (Split-Path $LogFile) -Force | Out-Null }
Function LogWrite { param($Message) Add-Content -Path $LogFile -Value $Message }

LogWrite "----------------------------------------"
LogWrite "System Health Check: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
LogWrite "----------------------------------------"
$CpuLoad = (Get-CimInstance Win32_Processor).LoadPercentage; LogWrite ">>> CPU Load: $CpuLoad %`n"
LogWrite ">>> Top 5 Processes by CPU:"; Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 Name, Id, CPU | Format-Table -AutoSize | Out-String | LogWrite; LogWrite ""
LogWrite ">>> Top 5 Processes by Memory (WS):"; Get-Process | Sort-Object WS -Descending | Select-Object -First 5 Name, Id, @{Name='WS(MB)';Expression={$_.WS / 1MB}} | Format-Table -AutoSize | Out-String | LogWrite; LogWrite ""
LogWrite ">>> Disk Usage:"; Get-CimInstance Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3} | Select-Object DeviceID, @{Name='Size(GB)'; Expression={[math]::Round($_.Size / 1GB, 2)}}, @{Name='Free(GB)'; Expression={[math]::Round($_.FreeSpace / 1GB, 2)}}, @{Name='Free(%)'; Expression={[math]::Round(($_.FreeSpace / $_.Size * 100), 2)}} | Format-Table -AutoSize | Out-String | LogWrite; LogWrite ""
LogWrite ">>> Recent Application/System Errors (Last Hour):"
$StartTime = (Get-Date).AddHours(-1)
try { Get-WinEvent -FilterHashTable @{LogName='Application','System'; Level=1,2; StartTime=$StartTime} -MaxEvents 5 -ErrorAction Stop | Select-Object TimeCreated, LevelDisplayName, ProviderName, Message | Format-List | Out-String | LogWrite } catch { LogWrite "    No critical/error events found in Application/System logs in the last hour or error querying logs: $($_.Exception.Message)" }
LogWrite "`n--- Check Complete ---"
exit 0
