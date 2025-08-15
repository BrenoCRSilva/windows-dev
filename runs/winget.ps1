#!/usr/bin/env powershell

Write-Host "Installing applications via winget..."

# Browsers
winget install Google.Chrome
winget install Discord.Discord

# Window management
winget install LGUG2Z.komorebi
winget install LGUG2Z.whkd
winget install --id AmN.yasb
winget install --id Ookla.Speedtest.CLI -e
winget install RamenSoftware.Windhawk

# Terminal and shell
winget install wez.wezterm
winget upgrade wez.wezterm
winget install win32yank
winget install Starship.Starship

Write-Host "Winget installations complete!"
