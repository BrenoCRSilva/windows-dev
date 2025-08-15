#!/usr/bin/env powershell
param(
    [switch]$DryRun,
    [switch]$InstallWSL
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Write-Log {
    param([string]$Message)
    Write-Host "$Message" -ForegroundColor Green
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
    } else {
        Write-Host "[DRY_RUN]: Would execute $ScriptPath" -ForegroundColor Yellow
    }
}

Write-Log "--------- Windows Environment Setup ---------"

# Handle WSL installation if explicitly requested
if ($InstallWSL) {
    Write-Log "Installing WSL with ArchLinux..."
    Execute-Script "$scriptDir\runs\wsl.ps1"
    Write-Log "WSL setup complete!"
    Write-Log ""
    Write-Log "Next steps:"
    Write-Log "  1. In WSL: Run 'cd ~/personal/dev && ./run.sh' to install development tools"
    Write-Log "  2. In WSL: Run './dev-env.sh' to deploy WSL configuration files"
    return
}

# Run all installation scripts in order
Execute-Script "$scriptDir\runs\winget.ps1"
Execute-Script "$scriptDir\runs\font.ps1"
Execute-Script "$scriptDir\runs\scoop.ps1"
Execute-Script "$scriptDir\runs\configure.ps1"

Write-Log "--------- Windows Bootstrap Complete ---------"
Write-Log ""
Write-Log "Next steps:"
Write-Log "  1. Run '.\dev-env.ps1' to deploy Windows configuration files"
Write-Log "  2. (Optional) Run '.\run.ps1 -InstallWSL' to set up WSL with ArchLinux"
