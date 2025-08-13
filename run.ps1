#!/usr/bin/env powershell

param(
    [switch]$DryRun
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

# Run all installation scripts in order
Execute-Script "$scriptDir\runs\winget.ps1"
Execute-Script "$scriptDir\runs\scoop.ps1"
Execute-Script "$scriptDir\runs\configure.ps1"

Write-Log "--------- Installation Complete ---------"
Write-Log "Run .\dev-env.ps1 to deploy configuration files"