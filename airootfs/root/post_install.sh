#!/usr/bin/env bash
set -euo pipefail

# Create backup function
backup_if_exists() {
    if [ -e "$1" ]; then
        local backup="${1}.backup.$(date +%Y%m%d_%H%M%S)"
        cp -r "$1" "$backup"
        echo "Backed up $1 to $backup"
    fi
}

# Function to add line to file if it doesn't exist
add_line_if_missing() {
    local line="$1"
    local file="$2"
    if [ -f "$file" ] && grep -qF "$line" "$file"; then
        echo "Line already exists in $file, skipping"
    else
        echo "$line" >> "$file"
        echo "Added line to $file"
    fi
}

# Ensure installation occurs from home dir
cd ~

# Update package database and system
sudo pacman -Syu --noconfirm

# Install Git and required tools
sudo pacman -S --noconfirm git base-devel

# Install fonts
sudo pacman -S --noconfirm ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji noto-fonts-cjk ttf-dejavu jq gnome gnome-tweaks

# Rebuild font cache
fc-cache -fv

# Starship prompt installation
if ! command -v starship &> /dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

add_line_if_missing 'eval "$(starship init bash)"' ~/.bashrc
add_line_if_missing 'eval "$(starship init zsh)"' ~/.zshrc

# Zsh and plugins
sudo pacman -S --noconfirm zsh zsh-autosuggestions figlet exa zoxide fzf yad ghc dunst

# Oh-my-zsh install (unattended mode)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Zsh-autosuggestions plugin install
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# Yay AUR helper install
if ! command -v yay &> /dev/null; then
    cd ~
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
    rm -rf yay
fi

# AUR packages
yay -S --noconfirm brave-bin hyprshade visual-studio-code-bin waypaper

# Backup existing configs
backup_if_exists ~/.zshrc
backup_if_exists ~/.config

# Get SoloLinux config files
cd ~
if [ -d "SoloLinux_GUI" ]; then
    rm -rf SoloLinux_GUI
fi
git clone https://github.com/Solomon-DbW/SoloLinux_GUI

# Move config files carefully
if [ -f "SoloLinux_GUI/zshrcfile" ]; then
    cp SoloLinux_GUI/zshrcfile ~/.zshrc
fi

# Copy config files, creating .config if it doesn't exist
mkdir -p ~/.config
if [ -d "SoloLinux_GUI" ]; then
    # Copy contents but skip zshrcfile since we handled it separately
    find SoloLinux_GUI -mindepth 1 -maxdepth 1 ! -name 'zshrcfile' -exec cp -r {} ~/.config/ \;
fi

# Cleanup
rm -rf SoloLinux_GUI

# Install Hyprland and related packages
sudo pacman -S --noconfirm hyprland hyprpaper hyprlock waybar rofi fastfetch cpufetch brightnessctl kitty ly virt-manager networkmanager nvim emacs

# Enable services
sudo systemctl enable NetworkManager
sudo systemctl enable ly

# Making scripts executable
if [ -d ~/.config/hypr/scripts ]; then
    chmod +x ~/.config/hypr/scripts/*
fi

if [ -f ~/.config/waybar/switch_theme.sh ]; then
    chmod +x ~/.config/waybar/switch_theme.sh
fi

if [ -d ~/.config/waybar/scripts ]; then
    chmod +x ~/.config/waybar/scripts/*
fi

# Customize /etc/os-release for colour of #256897
sudo tee /etc/os-release > /dev/null <<'EOF'
NAME="SoloLinux"
PRETTY_NAME="SoloLinux"
ID=sololinux
ID_LIKE=arch
BUILD_ID=rolling
ANSI_COLOR="0;38;2;37;104;151"
HOME_URL="https://github.com/Solomon-DbW/SoloLinuxISO"
DOCUMENTATION_URL="https://github.com/Solomon-DbW/SoloLinuxISO"
SUPPORT_URL="https://github.com/Solomon-DbW/SoloLinuxISO"
BUG_REPORT_URL="https://github.com/Solomon-DbW/SoloLinuxISO"
PRIVACY_POLICY_URL="https://github.com/Solomon-DbW/SoloLinuxISO"
LOGO=archlinux-logo
EOF

# Rebuild font cache one final time
fc-cache -fv

# Change shell (requires logout to take effect)
sudo chsh -s "$(which zsh)" "$USER"

echo "=========================================="
echo "Setup complete! Please log out and log back in."
echo "Select Hyprland from the display manager to start the SoloLinux GUI."
echo "=========================================="

# #!/usr/bin/env bash
# set -euo pipefail  # Add -u for unset variables, -o pipefail for pipe failures
#
# # Create backup function
# backup_if_exists() {
#     if [ -e "$1" ]; then
#         local backup="${1}.backup.$(date +%Y%m%d_%H%M%S)"
#         cp -r "$1" "$backup"
#         echo "Backed up $1 to $backup"
#     fi
# }
#
# # Ensure installation occurs from home dir
# cd ~
#
# sudo pacman -Sy
#
# # Install Git and required tools
# sudo pacman -S --noconfirm git base-devel
#
# # Install fonts
# sudo pacman -S --noconfirm ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji noto-fonts-cjk ttf-dejavu jq gnome gnome-tweaks
# fc-cache -fv
#
# # Starship prompt installation
# curl -sS https://starship.rs/install.sh | sh -s -- -y
# echo 'eval "$(starship init bash)"' >> ~/.bashrc   
# echo 'eval "$(starship init zsh)"' >> ~/.zshrc
#
# # Zsh and plugins
# sudo pacman -S --noconfirm zsh zsh-autosuggestions figlet exa zoxide fzf yad ghc dunst # dunst is for notifs and yad is for cheatsheet
#
# # Oh-my-zsh install
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
#
# # Zsh-autossugestions plugin install
# git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
#
# # Yay AUR helper install
# if ! command -v yay &> /dev/null; then
#     cd ~
#     git clone https://aur.archlinux.org/yay.git
#     cd yay
#     makepkg -si --noconfirm
#     cd ~
#     rm -rf yay  # Cleanup
# fi
#
# # AUR packages
# yay -S --noconfirm brave-bin hyprshade visual-studio-code-bin waypaper
#
# # Backup existing configs
# backup_if_exists ~/.zshrc
# backup_if_exists ~/.config
#
# # Get SoloLinux config files
# cd ~
# git clone https://github.com/Solomon-DbW/SoloLinux_GUI
# # git clone https://github.com/Solomon-DbW/SoloLinux
#
# # Move config files carefully
# cp SoloLinux_GUI/zshrcfile ~/.zshrc
# cp -r SoloLinux_GUI/* ~/.config/ 2>/dev/null || true
# # cp -r SoloLinux/kitty ~/.config/
#
# # Cleanup
# rm -rf SoloLinux_GUI SoloLinux
#
# # Install Hyprland and related packages
# sudo pacman -S --noconfirm hyprland hyprpaper hyprlock waybar rofi fastfetch cpufetch brightnessctl kitty ly virt-manager networkmanager nvim emacs
#
# # Enable services
# sudo systemctl enable NetworkManager
# sudo systemctl enable ly
#
# # Making scripts executable
# chmod +x ~/.config/hypr/scripts/* 2>/dev/null || true
# chmod +x ~/.config/waybar/switch_theme.sh ~/.config/waybar/scripts/* 2>/dev/null || true
#
# # Customize /etc/os-release for colour of #256897
# sudo tee /etc/os-release > /dev/null <<'EOF'
# NAME="SoloLinux"
# PRETTY_NAME="SoloLinux"
# ID=sololinux
# ID_LIKE=arch
# BUILD_ID=rolling
# ANSI_COLOR="0;38;2;37;104;151"
# HOME_URL="https://github.com/Solomon-DbW/SoloLinuxISO"
# DOCUMENTATION_URL="https://github.com/Solomon-DbW/SoloLinuxISO"
# SUPPORT_URL="https://github.com/Solomon-DbW/SoloLinuxISO"
# BUG_REPORT_URL="https://github.com/Solomon-DbW/SoloLinuxISO"
# PRIVACY_POLICY_URL="https://github.com/Solomon-DbW/SoloLinuxISO"
# LOGO=archlinux-logo
# EOF
#
# # Change shell (will take effect after logout)
# chsh -s $(which zsh)
#
# echo "Setup complete! Please log out and log back in."
# echo "Select Hyprland from the display manager to start the SoloLinux GUI."
