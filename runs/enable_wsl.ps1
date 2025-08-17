# Check if WSL is already working
$wslWorking = try {
    wsl --status 2>$null
    $true
} catch {
    $false
}

if ($wslWorking) {
    Write-Host "WSL features already enabled!" -ForegroundColor Green
    return
}

# Self-elevate if not admin
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process PowerShell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`"" -Wait
    exit 0
}

Write-Host "Enabling WSL features..." -ForegroundColor Yellow

dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

$response = Read-Host "Restart now? (y/n)"
if ($response -eq 'y' -or $response -eq 'Y') {
    Restart-Computer -Force
}
