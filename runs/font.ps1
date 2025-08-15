#!/usr/bin/env powershell

$fontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip"
$downloadPath = "$env:TEMP\font.zip"
$extractPath = "$env:TEMP\font"

Write-Host "Installing FiraCode Nerd Font..." -ForegroundColor Cyan

# Download
Write-Host "Downloading..." -ForegroundColor Yellow
Invoke-WebRequest -Uri $fontUrl -OutFile $downloadPath

# Extract
Write-Host "Extracting..." -ForegroundColor Yellow
Expand-Archive -Path $downloadPath -DestinationPath $extractPath -Force

# Install fonts (copy to Windows Fonts folder)
Write-Host "Installing fonts..." -ForegroundColor Yellow
$fontsFolder = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
if (!(Test-Path $fontsFolder)) {
    New-Item -ItemType Directory -Path $fontsFolder -Force
}
Get-ChildItem "$extractPath\*.ttf" | ForEach-Object {
   Copy-Item $_.FullName $fontsFolder -Force
   Write-Host "Installed: $($_.Name)" -ForegroundColor Green
}

# Cleanup
Remove-Item $downloadPath -Force
Remove-Item $extractPath -Recurse -Force

Write-Host "FiraCode Nerd Font installation complete!" -ForegroundColor Green
