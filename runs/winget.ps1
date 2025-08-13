#!/usr/bin/env powershell

Write-Host "Installing applications via winget..."

# Browsers
winget install Google.Chrome
winget install Discord.Discord

# Terminal and shell
winget install Microsoft.WindowsTerminal
winget install Starship.Starship

Write-Host "Winget installations complete!"