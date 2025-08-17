Write-Host "Installing Scoop and tools..."

# Install Scoop if not present
if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-RestMethod get.scoop.sh | Invoke-Expression
}

# Add required buckets
scoop bucket add extras
scoop bucket add nerd-fonts

#Install NerdFont and Kanata
scoop install extras/kanata
scoop install FiraCode-NF


Write-Host "Scoop installations complete!"
