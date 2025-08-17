Write-Host "Starting PowerShell environment setup..." -ForegroundColor Cyan

# Configure Starship prompt
Write-Host "Configuring shell and prompt..."
$starshipContent = 'Invoke-Expression (&starship init powershell)'
if (!(Get-Content $PROFILE -ErrorAction SilentlyContinue | Select-String "starship")) {
    Add-Content $PROFILE $starshipContent
    Write-Host "Added Starship to PowerShell profile" -ForegroundColor Green
} else {
    Write-Host "Starship already configured in profile" -ForegroundColor Yellow
}

# Configure Komorebi
Write-Host "Setting up Komorebi configuration..."
$configPath = "$env:USERPROFILE\.config\komorebi"

# Check if environment variable is already set
$currentValue = [Environment]::GetEnvironmentVariable("KOMOREBI_CONFIG_HOME", "User")
if ($currentValue -eq $configPath) {
    Write-Host "KOMOREBI_CONFIG_HOME already set to: $configPath" -ForegroundColor Yellow
} else {
    # Set environment variable permanently in registry
    [Environment]::SetEnvironmentVariable("KOMOREBI_CONFIG_HOME", $configPath, "User")
    Write-Host "KOMOREBI_CONFIG_HOME set to: $configPath" -ForegroundColor Green
}

Write-Host "Configuration complete!" -ForegroundColor Green
