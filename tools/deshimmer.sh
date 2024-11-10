#!/bin/bash

echo "🔍 Scanning for ASDF configurations..."

# Check common shell config files
shell_configs=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile" "$HOME/.bash_profile")

for config in "${shell_configs[@]}"; do
    if [ -f "$config" ]; then
        if grep -q "asdf.sh" "$config"; then
            echo "Found ASDF reference in $config"
            # Create backup
            cp "$config" "$config.backup"
            # Remove ASDF lines
            sed -i '/asdf.sh/d' "$config"
            echo "✅ Cleaned $config (backup created at $config.backup)"
        fi
    fi
done

# Check for ASDF directory
if [ -d "$HOME/.asdf" ]; then
    echo "📁 Found ASDF directory at $HOME/.asdf"
    read -p "Would you like to remove it? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$HOME/.asdf"
        echo "✅ Removed ASDF directory"
    fi
fi

# Check for system-wide ASDF installation
if [ -d "/opt/asdf-vm" ]; then
    echo "📁 Found system-wide ASDF installation at /opt/asdf-vm"
    echo "To remove this, you'll need sudo privileges"
    read -p "Would you like to remove it? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo rm -rf "/opt/asdf-vm"
        echo "✅ Removed system-wide ASDF installation"
    fi
fi

echo "🧹 Cleanup complete! Please restart your terminal for changes to take effect."