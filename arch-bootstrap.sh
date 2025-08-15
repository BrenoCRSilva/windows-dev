#!/usr/bin/env bash
set -euo pipefail

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "Please run as root (e.g., sudo su or login as root)."
    exit 1
fi

# Update system
echo "[*] Updating system..."
pacman -Syu --noconfirm

# Install basic packages
echo "[*] Installing sudo, git, openssh..."
pacman -S --noconfirm sudo git openssh

# Add new user
read -rp "Enter new username: " NEWUSER

# Basic username validation
if [[ ! "$NEWUSER" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
    echo "Error: Invalid username format. Use only lowercase letters, numbers, underscores, and hyphens."
    exit 1
fi

useradd -m -G wheel -s /bin/bash "$NEWUSER"
passwd "$NEWUSER"

# Add user to sudoers using /etc/sudoers.d/
echo "[*] Adding $NEWUSER to sudoers..."
cat > "/etc/sudoers.d/$NEWUSER" <<EOF
$NEWUSER ALL=(ALL) ALL
EOF
chmod 440 "/etc/sudoers.d/$NEWUSER"

# Validate sudoers configuration
if ! visudo -c -q; then
    echo "Error: Invalid sudoers configuration. Removing rule."
    rm "/etc/sudoers.d/$NEWUSER"
    exit 1
fi

echo "[*] Sudoers rule added and validated successfully."

# Enable SSH service
echo "[*] Enabling SSH service..."
systemctl enable --now sshd

# Switch to new user for the rest of setup
su - "$NEWUSER" <<EOF
set -euo pipefail

# SSH setup
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# SSH key setup for GitHub access
echo "[*] Setting up SSH keys for GitHub access..."
echo ""
echo "To clone your wsl-dev repo, you need to import your existing GitHub SSH key."
echo ""

# Temporarily disable history for sensitive operations
set +o history

# Public key input
echo "Paste your SSH PUBLIC key (single line, press Enter when done):"
read -r PUBKEY
if [[ -n "\$PUBKEY" ]]; then
    echo "\$PUBKEY" > ~/.ssh/id_ed25519.pub
    chmod 644 ~/.ssh/id_ed25519.pub
    echo "[*] Public key installed."
else
    echo "Error: Public key is required for GitHub access."
    set -o history
    exit 1
fi

# Private key input
echo ""
echo "Paste your SSH PRIVATE key (multi-line, press Ctrl+D when finished):"
echo "-----BEGIN OPENSSH PRIVATE KEY-----"
PRIVKEY=\$(cat)
if [[ -n "\$PRIVKEY" ]]; then
    echo "\$PRIVKEY" > ~/.ssh/id_ed25519
    chmod 600 ~/.ssh/id_ed25519
    echo "[*] Private key installed."
    
    # Validate key pair
    if ssh-keygen -l -f ~/.ssh/id_ed25519 >/dev/null 2>&1; then
        echo "[*] SSH key validated successfully."
    else
        echo "Error: Invalid private key format."
        set -o history
        exit 1
    fi
else
    echo "Error: Private key is required for GitHub access."
    set -o history
    exit 1
fi

# Test GitHub connection
echo "[*] Testing GitHub connection..."
if ssh -T git@github.com -o StrictHostKeyChecking=no -o ConnectTimeout=10 2>&1 | grep -q "successfully authenticated"; then
    echo "[*] GitHub SSH connection successful!"
else
    echo "Warning: GitHub SSH test failed. Check your key or network connection."
fi

# Clear sensitive variables and re-enable history
unset PUBKEY PRIVKEY
set -o history

# Skip displaying public key - user already has it

# Install paru
echo "[*] Installing paru..."
sudo pacman -S --needed --noconfirm base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si --noconfirm
cd ..
rm -rf paru
echo "[*] Paru installed successfully."

# Clone wsl-dev repository
echo "[*] Cloning wsl-dev repository..."
mkdir -p ~/personal
if [ ! -d ~/personal/dev ]; then
    git clone git@github.com:BrenoCRSilva/wsl-dev.git ~/personal/dev
    echo "[*] wsl-dev repository cloned to ~/personal/dev"
else
    echo "[*] wsl-dev repository already exists at ~/personal/dev"
fi

echo ""
echo "[*] Bootstrap complete! Summary:"
echo "  - System updated"
echo "  - User '$NEWUSER' created with sudo access" 
echo "  - SSH service enabled"
echo "  - SSH keys configured"
echo "  - Paru AUR helper installed"
echo "  - wsl-dev repository cloned"
echo ""
echo "Next steps:"
echo "  1. Run 'cd ~/personal/dev && ./run.sh' to install development tools"
echo "  2. Run './dev-env.sh' to deploy configuration files"
echo ""
echo "You are now logged in as $NEWUSER. Ready to continue setup!"
EOF
