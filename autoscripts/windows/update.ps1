# Script to check and install Windows Updates (requires Administrator privileges and PSWindowsUpdate module)
#Requires -Modules PSWindowsUpdate
#Requires -RunAsAdministrator

$LogFile = "C:\Automation\Logs\update.log"
if (-not (Test-Path (Split-Path $LogFile) -PathType Container)) { New-Item -ItemType Directory -Path (Split-Path $LogFile) -Force | Out-Null }
Function LogWrite { param($Message) Add-Content -Path $LogFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message" }

LogWrite "======================================"
LogWrite "Starting Windows Update check/install..."
LogWrite "======================================"

# Check if module exists first, otherwise the script will fail if #Requires is used and module isn't present
if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
     LogWrite "ERROR: PSWindowsUpdate module is not installed. Please install it on the agent: Install-Module PSWindowsUpdate"
     exit 1 # Exit script if prerequisite module is missing
}

Import-Module PSWindowsUpdate -Force -ErrorAction SilentlyContinue

try {
    LogWrite "Checking for available updates using PSWindowsUpdate module..."
    # Log Verbose stream to the log file
    Get-WUInstall -AcceptAll -Install -Verbose *>&1 | Out-File -Append -FilePath $LogFile -Encoding UTF8
    LogWrite "Windows Update check/install process completed via PSWindowsUpdate."
} catch {
     LogWrite "ERROR: Windows Update check/install failed: $($_.Exception.Message)"
     exit 1
}
LogWrite "======================================" ; LogWrite "Update script finished." ; LogWrite "======================================"
exit 0
