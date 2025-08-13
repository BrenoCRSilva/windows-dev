#!/usr/bin/env powershell

Write-Host "Installing applications via winget..."

# Browsers
winget install Google.Chrome
winget install Discord.Discord

# Ricing
winget install RamenSoftware.Windhawk

# Terminal and shell
winget install Notepad++.Notepad++
winget install Microsoft.WindowsTerminal
winget install Starship.Starship

Write-Host "Winget installations complete!"