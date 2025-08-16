#!/usr/bin/env bash
set -euo pipefail

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "Please run as root (e.g., sudo su or login as root)."
    exit 1
fi

passwd

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
$NEWUSER ALL=(ALL) NOPASSWD: ALL
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

# SSH key setup (done as root, then copied to user)
echo "[*] Setting up SSH keys for GitHub access..."
echo ""
echo "To clone your wsl-dev repo, you need to import your existing GitHub SSH key."
echo ""

# Public key input
echo "Paste your SSH PUBLIC key (single line, press Enter when done):"
read -r PUBKEY

if [[ -z "$PUBKEY" ]]; then
    echo "Error: Public key is required for GitHub access."
    exit 1
fi

# Private key input
echo ""
echo "Paste your SSH PRIVATE key (multi-line, press Ctrl+D when finished):"
PRIVKEY=$(cat)

if [[ -z "$PRIVKEY" ]]; then
    echo "Error: Private key is required for GitHub access."
    exit 1
fi

# Setup SSH directory and keys for user
echo "[*] Installing SSH keys for user $NEWUSER..."
mkdir -p "/home/$NEWUSER/.ssh"
echo "$PUBKEY" > "/home/$NEWUSER/.ssh/id_ed25519.pub"
echo "$PRIVKEY" > "/home/$NEWUSER/.ssh/id_ed25519"
ssh-keyscan github.com >> "/home/$NEWUSER/.ssh/known_hosts"

# Set proper permissions
chmod 700 "/home/$NEWUSER/.ssh"
chmod 644 "/home/$NEWUSER/.ssh/id_ed25519.pub"
chmod 600 "/home/$NEWUSER/.ssh/id_ed25519"
chmod 644 "/home/$NEWUSER/.ssh/known_hosts"
chown -R "$NEWUSER:$NEWUSER" "/home/$NEWUSER/.ssh"

# Validate key pair
if ssh-keygen -l -f "/home/$NEWUSER/.ssh/id_ed25519" >/dev/null 2>&1; then
    echo "[*] SSH key validated successfully."
else
    echo "Error: Invalid private key format."
    exit 1
fi

# Create user setup script
cat > "/home/$NEWUSER/user_setup.sh" << 'USERSCRIPT'
#!/bin/bash
set -euo pipefail

echo "Running as $(whoami), home is $HOME"

# Install paru
echo "[*] Installing paru..."
sudo pacman -S --needed --noconfirm base-devel rustup
rustup default stable
rustup toolchain install nightly
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
    git clone --recursive git@github.com:BrenoCRSilva/wsl-dev.git ~/personal/dev
    echo "[*] wsl-dev repository cloned to ~/personal/dev"
else
    echo "[*] wsl-dev repository already exists at ~/personal/dev"
fi

echo ""
echo "[*] Bootstrap complete! Summary:"
echo "  - System updated"
echo "  - User created with sudo access" 
echo "  - SSH service enabled"
echo "  - SSH keys configured"
echo "  - Paru AUR helper installed"
echo "  - wsl-dev repository cloned"
echo ""
USERSCRIPT

# Set proper ownership and permissions
chown "$NEWUSER:$NEWUSER" "/home/$NEWUSER/user_setup.sh"
chmod +x "/home/$NEWUSER/user_setup.sh"

echo "[*] Switching to user $NEWUSER for remaining setup..."
su -l "$NEWUSER" << 'EOF'
./user_setup.sh
EOF

while true; do
    read -rp "Would you like to install the requirements for DEV? [y/n]: " CONF
    if [[ "$CONF" == "y" ]]; then
        echo "[*] Installing development requirements..."
        su -l "$NEWUSER" -c "cd ~/personal/dev && ./run.sh"
        break
    elif [[ "$CONF" == "n" ]]; then
        echo "[*] Skipping development requirements installation."
        break
    else
        echo "Invalid entry. Please enter 'y' or 'n'."
    fi
done

while true; do
    read -rp "Would you like to set your DEV ENV? [y/n]: " CONF
    if [[ "$CONF" == "y" ]]; then
        echo "[*] Installing development requirements..."
        su -l "$NEWUSER" -c "cd ~/personal/dev && ./dev-env.sh"
        break
    elif [[ "$CONF" == "n" ]]; then
        echo "[*] Skipping setting environment."
        break
    else
        echo "Invalid entry. Please enter 'y' or 'n'."
    fi
done
