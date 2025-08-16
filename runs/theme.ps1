# Self-elevate if not admin
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process PowerShell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`""
    exit
}

# Registry paths
$p = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
$dwm = "HKCU:\SOFTWARE\Microsoft\Windows\DWM"
$explorer = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Accent"

# Create paths if needed
if (!(Test-Path $p)) { New-Item -Path $p -Force | Out-Null }
if (!(Test-Path $dwm)) { New-Item -Path $dwm -Force | Out-Null }
if (!(Test-Path $explorer)) { New-Item -Path $explorer -Force | Out-Null }

# Rose Pine base color #191724 - convert to ABGR format
# RGB: 19(0x19), 17(0x17), 24(0x24) -> ABGR: FF241719
$color = 0xFF241719

# Dark mode, no transparency, Rose Pine base color
Set-ItemProperty -Path $p -Name "AppsUseLightTheme" -Value 0
Set-ItemProperty -Path $p -Name "SystemUsesLightTheme" -Value 0
Set-ItemProperty -Path $p -Name "EnableTransparency" -Value 0
Set-ItemProperty -Path $p -Name "AccentColor" -Value $color
Set-ItemProperty -Path $p -Name "ColorPrevalence" -Value 1

# Accent color on title bars and taskbar
Set-ItemProperty -Path $dwm -Name "ColorPrevalence" -Value 1
Set-ItemProperty -Path $dwm -Name "AccentColor" -Value $color

# Set accent color for taskbar and Start menu
Set-ItemProperty -Path $explorer -Name "AccentColorMenu" -Value $color
Set-ItemProperty -Path $explorer -Name "StartColorMenu" -Value $color

# Restart explorer
Stop-Process -Name "explorer" -Force
Start-Sleep 2

# Force registry refresh
rundll32.exe user32.dll,UpdatePerUserSystemParameters