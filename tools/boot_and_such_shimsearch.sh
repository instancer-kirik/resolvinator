#!/bin/bash

echo "🔍 Scanning for shims, startup items, and boot configurations..."

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function to check file contents
check_file() {
    local file=$1
    if [ -f "$file" ]; then
        echo -e "\n${BLUE}Checking ${file}:${NC}"
        grep -n "source \|. \|\.\/\|export PATH=\|eval \"\$(.*)\"\|load\[" "$file" 2>/dev/null | \
        while read -r line; do
            echo -e "${GREEN}Line $(echo $line | cut -d: -f1):${NC} $(echo $line | cut -d: -f2-)"
        done
    fi
}

echo -e "\n${BLUE}=== Startup Locations ===${NC}"

# Systemd user services
echo -e "\n${BLUE}Checking systemd user services:${NC}"
systemd_user_dirs=(
    "$HOME/.config/systemd/user/"
    "/etc/systemd/user/"
    "/usr/lib/systemd/user/"
)
for dir in "${systemd_user_dirs[@]}"; do
    if [ -d "$dir" ]; then
        echo -e "${RED}Found user services in:${NC} $dir"
        ls -la "$dir"/*.service 2>/dev/null
    fi
done

# Systemd system services
echo -e "\n${BLUE}Checking systemd system services:${NC}"
systemd_system_dirs=(
    "/etc/systemd/system/"
    "/usr/lib/systemd/system/"
)
for dir in "${systemd_system_dirs[@]}"; do
    if [ -d "$dir" ]; then
        echo -e "${RED}Found system services in:${NC} $dir"
        ls -la "$dir"/*.service 2>/dev/null
    fi
done

# XDG autostart
echo -e "\n${BLUE}Checking XDG autostart entries:${NC}"
xdg_dirs=(
    "$HOME/.config/autostart/"
    "/etc/xdg/autostart/"
)
for dir in "${xdg_dirs[@]}"; do
    if [ -d "$dir" ]; then
        echo -e "${RED}Found autostart entries in:${NC} $dir"
        ls -la "$dir"/*.desktop 2>/dev/null
    fi
done

# Init.d scripts
echo -e "\n${BLUE}Checking init.d scripts:${NC}"
if [ -d "/etc/init.d" ]; then
    echo -e "${RED}Found init.d scripts:${NC}"
    ls -la /etc/init.d/
fi

# Crontabs
echo -e "\n${BLUE}Checking crontabs:${NC}"
if [ -d "/etc/cron.d" ]; then
    echo "System cron.d contents:"
    ls -la /etc/cron.d/
fi
for crontab in /etc/cron.*/*; do
    if [ -f "$crontab" ]; then
        echo "Found crontab: $crontab"
    fi
done

# User crontab
if command -v crontab >/dev/null 2>&1; then
    echo -e "\n${BLUE}Current user's crontab:${NC}"
    crontab -l 2>/dev/null || echo "No user crontab found"
fi

echo -e "\n${BLUE}=== Shell Initialization Files ===${NC}"
# Previous shell config checking code here...
config_files=(
    "$HOME/.bashrc"
    "$HOME/.zshrc"
    "$HOME/.profile"
    "$HOME/.bash_profile"
    "$HOME/.zprofile"
    "$HOME/.bash_aliases"
    "$HOME/.zshenv"
    "/etc/profile"
    "/etc/bash.bashrc"
)

for file in "${config_files[@]}"; do
    check_file "$file"
done

echo -e "\n${BLUE}=== Boot Configuration ===${NC}"
# Check GRUB configuration
if [ -f "/etc/default/grub" ]; then
    echo -e "\n${BLUE}GRUB configuration:${NC}"
    grep -v "^#" /etc/default/grub | grep -v "^$"
fi

# Check kernel modules
echo -e "\n${BLUE}Checking kernel modules:${NC}"
if [ -d "/etc/modules-load.d" ]; then
    echo "Contents of /etc/modules-load.d/:"
    ls -la /etc/modules-load.d/
fi

# Check rc.local
if [ -f "/etc/rc.local" ]; then
    echo -e "\n${BLUE}Checking rc.local:${NC}"
    grep -v "^#" /etc/rc.local | grep -v "^$"
fi

# Check for snap services
if command -v snap >/dev/null 2>&1; then
    echo -e "\n${BLUE}Checking snap services:${NC}"
    snap services 2>/dev/null
fi

# Check for flatpak autostart
if command -v flatpak >/dev/null 2>&1; then
    echo -e "\n${BLUE}Checking Flatpak autostart entries:${NC}"
    flatpak list --app --show-details 2>/dev/null
fi

# Version managers (previous code)
echo -e "\n${BLUE}=== Version Managers ===${NC}"
version_managers=(
    "$HOME/.asdf"
    "$HOME/.nvm"
    "$HOME/.rvm"
    "$HOME/.rbenv"
    "$HOME/.pyenv"
    "$HOME/.sdkman"
    "/opt/asdf-vm"
)

for vm in "${version_managers[@]}"; do
    if [ -d "$vm" ]; then
        echo -e "${RED}Found version manager:${NC} $vm"
    fi
done

# Shim directories (previous code)
echo -e "\n${BLUE}=== Shim Directories ===${NC}"
shim_dirs=(
    "$HOME/.asdf/shims"
    "$HOME/.rbenv/shims"
    "$HOME/.pyenv/shims"
    "$HOME/.local/share/*/shims"
)

for dir in "${shim_dirs[@]}"; do
    if [ -d "$dir" ]; then
        echo -e "${RED}Found shim directory:${NC} $dir"
        echo "Contents:"
        ls -la "$dir" | head -n 5
        count=$(ls "$dir" | wc -l)
        if [ $count -gt 5 ]; then
            echo "... and $((count - 5)) more files"
        fi
    fi
done

echo -e "\n${BLUE}=== PATH Analysis ===${NC}"
echo "Current PATH entries:"
echo $PATH | tr ':' '\n' | grep -i "shims\|\.local\|version\|manager"

echo -e "\n🏁 Scan complete!" 