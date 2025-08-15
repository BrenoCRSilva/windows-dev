#!/usr/bin/env powershell
param(
    [switch]$DryRun
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Write-Log {
    param([string]$Message, [string]$Color = "Green")
    if ($DryRun) {
        Write-Host "[DRY_RUN]: $Message" -ForegroundColor Yellow
    } else {
        Write-Host "$Message" -ForegroundColor $Color
    }
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
        wsl --install archlinux
        Write-Log "ArchLinux installed and ready."
    }
} else {
    Write-Log "ArchLinux WSL already installed." -Color Yellow
}

# Copy arch-bootstrap.sh to WSL and run it
Write-Log "Copying and running arch-bootstrap.sh..."
if (!$DryRun) {
    $bootstrapPath = Join-Path $scriptDir ".." "arch-bootstrap.sh"
    
    if (!(Test-Path $bootstrapPath)) {
        Write-Error "arch-bootstrap.sh not found at $bootstrapPath"
        exit 1
    }
    
    # Copy arch-bootstrap.sh to WSL home directory
    wsl -d archlinux -- bash -c "mkdir -p /tmp"
    Get-Content $bootstrapPath | wsl -d archlinux -- bash -c "cat > /tmp/arch-bootstrap.sh"
    
    # Run arch-bootstrap.sh
    wsl -d archlinux -- bash -c "chmod +x /tmp/arch-bootstrap.sh && bash /tmp/arch-bootstrap.sh"
    
    Write-Log "arch-bootstrap.sh completed successfully!"
} else {
    Write-Host "[DRY_RUN]: Would copy arch-bootstrap.sh and execute it in WSL" -ForegroundColor Yellow
}

Write-Log "WSL setup complete!"
