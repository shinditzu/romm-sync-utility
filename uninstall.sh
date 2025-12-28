#!/bin/bash
# RomM Sync Utility - Uninstaller

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

INSTALL_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/romm-sync"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  RomM Sync Utility - Uninstaller${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

print_status() {
    echo -e "${BLUE}[*]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Confirm uninstallation
read -p "Are you sure you want to uninstall RomM Sync? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstall cancelled."
    exit 0
fi

echo ""

# Remove installed commands
print_status "Removing installed commands..."
rm -f "$INSTALL_DIR/romm-sync"
rm -f "$INSTALL_DIR/romm-sync-retropie"
rm -f "$INSTALL_DIR/romm-sync-steamdeck"
print_success "Removed commands"

# Ask about config directory
echo ""
read -p "Remove configuration directory ($CONFIG_DIR)? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf "$CONFIG_DIR"
    print_success "Removed configuration directory"
else
    print_warning "Kept configuration directory"
fi

# Check for PATH modifications
SHELL_CONFIGS=("$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.zshrc")
for config in "${SHELL_CONFIGS[@]}"; do
    if [ -f "$config" ] && grep -q "Added by RomM Sync installer" "$config"; then
        print_warning "Found PATH modification in $config"
        echo "You may want to manually remove the lines added by the installer:"
        echo "  # Added by RomM Sync installer"
        echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi
done

echo ""
echo -e "${GREEN}Uninstallation complete!${NC}"
echo ""
