#!/usr/bin/env powershell

Write-Host "Configuring shell and prompt..."

# Add starship to PowerShell profile
$profileContent = 'Invoke-Expression (&starship init powershell)'

if (!(Test-Path $PROFILE)) {
    New-Item -Path $PROFILE -Type File -Force | Out-Null
}

if (!(Get-Content $PROFILE | Select-String "starship")) {
    Add-Content $PROFILE $profileContent
    Write-Host "Added Starship to PowerShell profile"
} else {
    Write-Host "Starship already configured in profile"
}

Write-Host "Configuration complete!"