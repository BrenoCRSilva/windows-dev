#!/usr/bin/env powershell

param(
    [switch]$DryRun
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Write-Log {
    param([string]$Message)
    if ($DryRun) {
        Write-Host "[DRY_RUN]: $Message" -ForegroundColor Yellow
    } else {
        Write-Host "$Message" -ForegroundColor Green
    }
}

function Copy-ConfigDir {
    param([string]$Source, [string]$Destination)
    
    if (!(Test-Path $Source)) {
        Write-Log "Warning: Source '$Source' does not exist, skipping"
        return
    }
    
    Write-Log "Copying $Source -> $Destination"
    
    if (!$DryRun) {
        if (Test-Path $Destination) {
            Remove-Item -Recurse -Force $Destination
        }
        Copy-Item -Recurse $Source $Destination
    }
}

function Copy-ConfigFile {
    param([string]$Source, [string]$Destination)
    
    if (!(Test-Path $Source)) {
        Write-Log "Warning: Source '$Source' does not exist, skipping"
        return
    }
    
    Write-Log "Copying $Source -> $Destination"
    
     if (-not $DryRun) {
        # Remove destination if it exists (like rm -rf)
        if (Test-Path $Destination) {
            Remove-Item -Path $Destination -Recurse -Force
        }

        $destDir = Split-Path -Parent $Destination
        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Force -Path $destDir | Out-Null
        }

        # Copy entire directory or file
        Copy-Item -Path $Source -Destination $Destination -Recurse -Force
    }}

# Set up paths
$configHome = "$env:USERPROFILE\.config"

Write-Log "--------- Windows Dev Environment Setup ---------"

# Copy config directories
Copy-ConfigDir "$scriptDir\env\.config\wezterm" "$configHome\wezterm"
Copy-ConfigDir "$scriptDir\env\.config\kanata" "$configHome\kanata"  
Copy-ConfigDir "$scriptDir\env\.config\komorebi" "$configHome\komorebi"
Copy-ConfigDir "$scriptDir\env\.config\yasb" "$configHome\yasb"
Copy-ConfigDir "$scriptDir\env\.config\windhawk" "$configHome\windhawk"
Copy-ConfigDir "$scriptDir\env\.config\wallpapers" "$configHome\wallpapers"

# Copy config files
Copy-ConfigFile "$scriptDir\env\.config\whkdrc" "$configHome\whkdrc"

Write-Log "--------- Setup Complete ---------"
