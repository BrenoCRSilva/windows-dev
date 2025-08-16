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
    param([string]$ScriptPath, [string[]]$Arguments = @())
    
    if (!(Test-Path $ScriptPath)) {
        Write-Host "Warning: Script '$ScriptPath' not found, skipping" -ForegroundColor Yellow
        return
    }
    
    Write-Log "Executing: $ScriptPath"
    
    if (!$DryRun) {
        if ($Arguments.Count -gt 0) {
            & $ScriptPath @Arguments
        } else {
            & $ScriptPath
        }
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Error: Script '$ScriptPath' failed with exit code $LASTEXITCODE" -ForegroundColor Red
            exit $LASTEXITCODE
        }
    } else {
        $argString = if ($Arguments.Count -gt 0) { " " + ($Arguments -join " ") } else { "" }
        Write-Host "[DRY_RUN]: Would execute $ScriptPath$argString" -ForegroundColor Yellow
    }
}

Write-Log "--------- Windows Environment Setup ---------"

# Handle WSL installation if explicitly requested
if ($InstallWSL) {
    $wslArgs = @()
    if ($DryRun) { $wslArgs += "-DryRun" }
    Execute-Script "$scriptDir\runs\enable_wsl.ps1"
    Execute-Script "$scriptDir\runs\wsl.ps1" $wslArgs
    
    if (!$DryRun) {
        Write-Log "Running arch-bootstrap.sh in WSL..."
        wsl -d archlinux --exec ./arch-bootstrap.sh
    } else {
        Write-Host "[DRY_RUN]: Would execute wsl -d archlinux --exec ./arch-bootstrap.sh" -ForegroundColor Yellow
    }
    return
}

# Run all installation scripts in order
Execute-Script "$scriptDir\runs\winget.ps1"
Execute-Script "$scriptDir\runs\scoop.ps1"
Execute-Script "$scriptDir\runs\configure.ps1"

Write-Log "--------- Windows Bootstrap Complete ---------"
Write-Log ""
Write-Log "Next steps:"
Write-Log "  1. Run '.\dev-env.ps1' to deploy Windows configuration files"
Write-Log "  2. (Optional) Run '.\run.ps1 -InstallWSL' to set up WSL with ArchLinux"