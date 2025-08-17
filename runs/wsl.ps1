param(
    [switch]$DryRun
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Write-Log {
    param(
        [string]$Message, 
        [string]$Color = "Green"
    )
    if ($DryRun) {
        Write-Host "[DRY_RUN]: $Message" -ForegroundColor Yellow
    } else {
        Write-Host "$Message" -ForegroundColor $Color
    }
}

function Execute-Script {
    param([string]$ScriptPath)
    
    if (!(Test-Path $ScriptPath)) {
        Write-Host "Warning: Script '$ScriptPath' not found, skipping" -ForegroundColor Yellow
        return
    }
    
    Write-Log "Executing: $ScriptPath"
    
    if (!$DryRun) {
        & $ScriptPath
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Error: Script '$ScriptPath' failed with exit code $LASTEXITCODE" -ForegroundColor Red
            exit $LASTEXITCODE
        }
    }
}

Write-Log "Installing WSL with ArchLinux..." -Color Cyan

# Check if WSL is already working
$wslWorking = try {
    wsl --status 2>$null
    $true
} catch {
    $false
}

if (-not $wslWorking) {
    Execute-Script "$scriptDir\enable_wsl.ps1"
    Write-Log "WSL features enabled!" -Color Cyan
    Write-Log ""
    Write-Log "Next steps:" -Color Cyan
    Write-Log "  1. Restart your computer"
    Write-Log "  2. After restart, run '.\run.ps1 -InstallWSL' again to install ArchLinux"
    return
}

Write-Log "--- WSL ArchLinux Setup ---" -Color Cyan

# Check if ArchLinux is already installed
$wslInstalled = try { 
    wsl --list --quiet 2>$null | Where-Object { $_ -match "archlinux" }
} catch { 
    $null 
}

if (-not $wslInstalled) {
    Write-Log "Installing WSL with ArchLinux..."
    if (!$DryRun) {
        Write-Log "Starting ArchLinux installation. This may take several minutes and will show download progress..." -Color Cyan
        $process = Start-Process -FilePath "wsl" -ArgumentList "--install", "archlinux", "--no-launch" -NoNewWindow -PassThru -Wait
        
        if ($process.ExitCode -ne 0) {
            Write-Error "Failed to install ArchLinux. Exit code: $($process.ExitCode)"
            exit 1
        }
        Write-Log "ArchLinux installed and ready." -ForegroundColor Green
    }
} else {
    Write-Log "ArchLinux WSL already installed." -ForegroundColor Yellow
}
