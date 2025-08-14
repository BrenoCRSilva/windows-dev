#!/usr/bin/env powershell

Write-Host "Installing Scoop and tools..."

# Install Scoop if not present
if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-RestMethod get.scoop.sh | Invoke-Expression
}

# Add required buckets
scoop bucket add extras

# Window management stack
scoop install wezterm
scoop install kanata
scoop install komorebi whkd
scoop install extras/yasb

Write-Host "Scoop installations complete!"