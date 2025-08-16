# Self-elevate if not admin
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process PowerShell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`""
    exit
}

# Function to restart explorer
function Restart-Explorer {
    Stop-Process -Name explorer -Force
    Start-Process explorer
}

# Hide taskbar search
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 0

# Turn off Task View button
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0

# Turn off widgets (Windows 11)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value 0

# Enable auto-hide taskbar
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3"
$settings = (Get-ItemProperty -Path $regPath -Name Settings).Settings
$settings[8] = $settings[8] -bor 0x02  # Set auto-hide bit
Set-ItemProperty -Path $regPath -Name Settings -Value $settings

# Restart Explorer to apply changes
Restart-Explorer

Write-Host "Taskbar settings updated successfully!"
