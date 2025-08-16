# Self-elevate if not admin
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process PowerShell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`""
    exit
}

# Registry paths
$search = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
$taskbar = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

# Create paths if needed
if (!(Test-Path $search)) { New-Item -Path $search -Force | Out-Null }
if (!(Test-Path $taskbar)) { New-Item -Path $taskbar -Force | Out-Null }

# Hide search box
Set-ItemProperty -Path $search -Name "SearchboxTaskbarMode" -Value 0

# Turn off Task View button
Set-ItemProperty -Path $taskbar -Name "ShowTaskViewButton" -Value 0


# Auto-hide taskbar (toggle-able) - Use StuckRects3 for proper auto-hide
$autoHide = $true  # Change to $false to turn off auto-hide

if ($autoHide) {
    # Enable auto-hide - modify StuckRects3 Settings binary
    $stuckRects = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3"
    if (!(Test-Path $stuckRects)) { New-Item -Path $stuckRects -Force | Out-Null }
    
    # Get current settings or create default
    try {
        $settings = Get-ItemProperty -Path $stuckRects -Name "Settings" -ErrorAction Stop
        $bytes = $settings.Settings
    } catch {
        # Default settings for primary monitor, taskbar at bottom
        $bytes = [byte[]](0x30,0x00,0x00,0x00,0xfe,0xff,0xff,0xff,0x02,0x00,0x00,0x00,0x03,0x00,0x00,0x00,0x3e,0x00,0x00,0x00,0x2e,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x80,0x07,0x00,0x00,0x38,0x04,0x00,0x00,0x00,0x00,0x00,0x00)
    }
    
    # Set auto-hide bit (bit 0 of byte 8)
    $bytes[8] = $bytes[8] -bor 0x01
    Set-ItemProperty -Path $stuckRects -Name "Settings" -Value $bytes
    
} else {
    # Disable auto-hide
    $stuckRects = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3"
    if (Test-Path $stuckRects) {
        try {
            $settings = Get-ItemProperty -Path $stuckRects -Name "Settings" -ErrorAction Stop
            $bytes = $settings.Settings
            # Clear auto-hide bit (bit 0 of byte 8)
            $bytes[8] = $bytes[8] -band 0xFE
            Set-ItemProperty -Path $stuckRects -Name "Settings" -Value $bytes
        } catch {
            Write-Host "No existing taskbar settings found to modify"
        }
    }
}

# Restart explorer
Stop-Process -Name "explorer" -Force