#!/bin/bash

echo "🔍 Scanning for shell initialization shims and source commands..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to check a file for shims and source commands
check_file() {
    local file=$1
    if [ -f "$file" ]; then
        echo -e "\n${BLUE}Checking ${file}:${NC}"
        
        # Look for common initialization patterns
        grep -n "source \|. \|\.\/\|export PATH=\|eval \"\$(.*)\"\|load\[" "$file" 2>/dev/null | \
        while read -r line; do
            echo -e "${GREEN}Line $(echo $line | cut -d: -f1):${NC} $(echo $line | cut -d: -f2-)"
        done
    fi
}

# Common configuration files to check
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

# Check each config file
for file in "${config_files[@]}"; do
    check_file "$file"
done

# Check profile.d directory
echo -e "\n${BLUE}Checking /etc/profile.d/:${NC}"
for file in /etc/profile.d/*.sh; do
    check_file "$file"
done

# Look for common version manager paths
echo -e "\n${BLUE}Checking for common version managers:${NC}"
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

# Look for binaries in common shim locations
echo -e "\n${BLUE}Checking for shim directories:${NC}"
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

# Check PATH for unusual entries
echo -e "\n${BLUE}Checking PATH for potential shim locations:${NC}"
echo $PATH | tr ':' '\n' | grep -i "shims\|\.local\|version\|manager"

echo -e "\n🏁 Scan complete!" 