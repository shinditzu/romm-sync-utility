#!/bin/bash
# RomM Sync Utility - Universal Installer
# Supports: RetroPie, SteamDeck (ES-DE), and generic Linux systems

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Installation directory
INSTALL_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/romm-sync"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  RomM Sync Utility - Installer${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to print status messages
print_status() {
    echo -e "${BLUE}[*]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Detect system type
detect_system() {
    if [ -d "$HOME/RetroPie" ]; then
        echo "retropie"
    elif [ -f "/etc/os-release" ] && grep -q "SteamOS" /etc/os-release; then
        echo "steamdeck"
    elif [ -d "$HOME/ES-DE" ]; then
        echo "steamdeck"
    else
        echo "generic"
    fi
}

SYSTEM_TYPE=$(detect_system)

echo -e "${GREEN}Detected system: ${SYSTEM_TYPE}${NC}"
echo ""

# Check for Python 3
print_status "Checking for Python 3..."
if ! command -v python3 &> /dev/null; then
    print_error "Python 3 is not installed!"
    echo "Please install Python 3.7 or higher and try again."
    exit 1
fi

PYTHON_VERSION=$(python3 --version | awk '{print $2}')
print_success "Found Python ${PYTHON_VERSION}"

# Check Python version (need 3.7+)
PYTHON_MAJOR=$(python3 -c 'import sys; print(sys.version_info.major)')
PYTHON_MINOR=$(python3 -c 'import sys; print(sys.version_info.minor)')

if [ "$PYTHON_MAJOR" -lt 3 ] || ([ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -lt 7 ]); then
    print_error "Python 3.7 or higher is required (found ${PYTHON_VERSION})"
    exit 1
fi

# Check for pip (skip for SteamDeck - will use venv's pip)
if [ "$SYSTEM_TYPE" != "steamdeck" ]; then
    print_status "Checking for pip..."
    if ! command -v pip3 &> /dev/null; then
        print_warning "pip3 not found, attempting to install..."
        
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y python3-pip
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm python-pip
        else
            print_error "Could not install pip automatically. Please install python3-pip manually."
            exit 1
        fi
    fi
    print_success "pip3 is available"
else
    print_status "Skipping pip check (SteamDeck will use venv)"
fi

# Install requests library (skip for SteamDeck - will be installed in venv)
if [ "$SYSTEM_TYPE" != "steamdeck" ]; then
    print_status "Installing Python dependencies..."
    if pip3 install --user requests --quiet 2>/dev/null; then
        print_success "Installed 'requests' library"
    else
        print_warning "Failed to install via pip3, trying alternative method..."
        
        # Try using ensurepip if pip install failed
        if python3 -m pip install --user requests --quiet 2>/dev/null; then
            print_success "Installed 'requests' library using python3 -m pip"
        else
            print_error "Failed to install 'requests' library"
            echo ""
            echo "Please install manually:"
            echo "  pip3 install --user requests"
            echo "Or:"
            echo "  python3 -m pip install --user requests"
            exit 1
        fi
    fi
else
    print_status "Skipping global pip install (will use venv for SteamDeck)"
fi

# Create installation directory
print_status "Creating installation directories..."
mkdir -p "$INSTALL_DIR"
mkdir -p "$CONFIG_DIR"
print_success "Created directories"

# Copy main script
print_status "Installing romm_sync.py..."
cp "$SCRIPT_DIR/romm_sync.py" "$INSTALL_DIR/romm-sync"
chmod +x "$INSTALL_DIR/romm-sync"
print_success "Installed romm-sync command"

# Create wrapper scripts for different targets
print_status "Creating convenience scripts..."

# RetroPie wrapper
if [ "$SYSTEM_TYPE" = "retropie" ]; then
    cat > "$INSTALL_DIR/romm-sync-retropie" << 'EOF'
#!/bin/bash
exec "$HOME/.local/bin/romm-sync" --target retropie "$@"
EOF
    chmod +x "$INSTALL_DIR/romm-sync-retropie"
    print_success "Created romm-sync-retropie wrapper"
fi

# SteamDeck wrapper
if [ "$SYSTEM_TYPE" = "steamdeck" ]; then
    cat > "$INSTALL_DIR/romm-sync-steamdeck" << 'EOF'
#!/bin/bash
exec "$HOME/.local/bin/romm-sync" --target steamdeck "$@"
EOF
    chmod +x "$INSTALL_DIR/romm-sync-steamdeck"
    print_success "Created romm-sync-steamdeck wrapper"
fi

# Check if ~/.local/bin is in PATH
print_status "Checking PATH configuration..."
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    print_warning "$HOME/.local/bin is not in your PATH"
    
    # Add to appropriate shell config
    SHELL_CONFIG=""
    if [ -f "$HOME/.bashrc" ]; then
        SHELL_CONFIG="$HOME/.bashrc"
    elif [ -f "$HOME/.bash_profile" ]; then
        SHELL_CONFIG="$HOME/.bash_profile"
    elif [ -f "$HOME/.zshrc" ]; then
        SHELL_CONFIG="$HOME/.zshrc"
    fi
    
    if [ -n "$SHELL_CONFIG" ]; then
        echo "" >> "$SHELL_CONFIG"
        echo "# Added by RomM Sync installer" >> "$SHELL_CONFIG"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_CONFIG"
        print_success "Added $HOME/.local/bin to PATH in $SHELL_CONFIG"
        print_warning "Please run: source $SHELL_CONFIG"
        print_warning "Or restart your terminal for changes to take effect"
    fi
else
    print_success "$HOME/.local/bin is already in PATH"
fi

# Create example config file
print_status "Creating example configuration..."
cat > "$CONFIG_DIR/config.example" << 'EOF'
# RomM Sync Configuration Example
# Copy this file to 'config' and edit with your settings
# Usage: romm-sync @config

ROMM_SERVER=https://your-romm-server.com
ROMM_USER=admin
ROMM_PASSWORD=your-password

# Optional: Uncomment to sync specific platforms only
# PLATFORMS=snes,nes,gba,genesis

# Optional: Uncomment to download ROM files
# DOWNLOAD_ROMS=true

# Optional: Uncomment to sync all ROMs (not just favorites)
# ALL_ROMS=true
EOF
print_success "Created example config at $CONFIG_DIR/config.example"

# System-specific setup
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  System-Specific Setup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

case "$SYSTEM_TYPE" in
    retropie)
        print_status "Setting up RetroPie integration..."
        
        # Create romm-sync directory
        mkdir -p "$HOME/romm-sync"
        
        # Copy sync-romm.sh if it exists
        if [ -f "$SCRIPT_DIR/sync-romm.sh" ]; then
            cp "$SCRIPT_DIR/sync-romm.sh" "$HOME/romm-sync/"
            chmod +x "$HOME/romm-sync/sync-romm.sh"
            print_success "Copied sync-romm.sh to ~/romm-sync/"
        fi
        
        # Create RetroPie menu entry (Ports menu)
        print_status "Creating EmulationStation Ports menu entry..."
        mkdir -p "$HOME/RetroPie/retropiemenu"
        
        cat > "$HOME/RetroPie/retropiemenu/romm-sync.sh" << 'MENUEOF'
#!/bin/bash
# RomM Sync - RetroPie Menu Entry
SCRIPT_DIR="${HOME}/romm-sync"
"${SCRIPT_DIR}/sync-romm.sh"
MENUEOF
        chmod +x "$HOME/RetroPie/retropiemenu/romm-sync.sh"
        
        # Create or update gamelist.xml for the menu entry
        GAMELIST_FILE="$HOME/RetroPie/retropiemenu/gamelist.xml"
        if [ -f "$GAMELIST_FILE" ]; then
            # Check if RomM Sync entry already exists
            if ! grep -q "romm-sync.sh" "$GAMELIST_FILE"; then
                # Add entry before closing </gameList> tag
                sed -i 's|</gameList>|  <game>\n    <path>./romm-sync.sh</path>\n    <name>RomM Sync</name>\n    <desc>Sync ROM metadata and files from RomM server</desc>\n  </game>\n</gameList>|' "$GAMELIST_FILE"
                print_success "Added RomM Sync to existing RetroPie menu"
            else
                print_success "RomM Sync already exists in RetroPie menu"
            fi
        else
            # Create new gamelist.xml
            cat > "$GAMELIST_FILE" << 'XMLEOF'
<?xml version="1.0"?>
<gameList>
  <game>
    <path>./romm-sync.sh</path>
    <name>RomM Sync</name>
    <desc>Sync ROM metadata and files from RomM server</desc>
  </game>
</gameList>
XMLEOF
            print_success "Created RetroPie menu entry"
        fi
        
        print_success "RetroPie setup complete"
        echo ""
        echo "Next steps:"
        echo "  1. Edit ~/.config/romm-sync/config.example with your RomM server details"
        echo "  2. Rename it to 'config'"
        echo "  3. Access 'RomM Sync' from the RetroPie menu in EmulationStation"
        echo "  4. Or run from SSH: romm-sync -s https://your-server.com -u admin -p password"
        echo ""
        echo "The RomM Sync option is now available in:"
        echo "  EmulationStation → RetroPie → RomM Sync"
        ;;
        
    steamdeck)
        print_status "Setting up SteamDeck integration (using venv)..."
        
        # Create romm-sync directory
        mkdir -p "$HOME/romm-sync"
        cd "$HOME/romm-sync"
        
        # Create virtual environment (avoids read-only filesystem issues)
        print_status "Creating Python virtual environment..."
        python3 -m venv venv
        print_success "Created virtual environment"
        
        # Install dependencies in venv
        print_status "Installing dependencies in venv..."
        source venv/bin/activate
        pip install --upgrade pip --quiet
        pip install requests --quiet
        deactivate
        print_success "Installed dependencies"
        
        # Copy romm_sync.py to the directory
        cp "$SCRIPT_DIR/romm_sync.py" "$HOME/romm-sync/romm_sync.py"
        print_success "Copied romm_sync.py"
        
        # Create wrapper script that uses venv
        print_status "Creating venv wrapper script..."
        cat > "$HOME/romm-sync/romm-sync" << 'WRAPPEREOF'
#!/bin/bash
# Wrapper script that auto-activates venv
cd ~/romm-sync
source venv/bin/activate
python romm_sync.py "$@"
deactivate
WRAPPEREOF
        chmod +x "$HOME/romm-sync/romm-sync"
        print_success "Created wrapper script"
        
        # Copy Steam launcher script
        print_status "Installing Steam launcher script..."
        if [ -f "$SCRIPT_DIR/steam-launcher.sh" ]; then
            cp "$SCRIPT_DIR/steam-launcher.sh" "$HOME/romm-sync/"
            chmod +x "$HOME/romm-sync/steam-launcher.sh"
            print_success "Copied steam-launcher.sh"
        else
            print_error "steam-launcher.sh not found in repository"
            exit 1
        fi
        
        # Create desktop entry for non-Steam game
        print_status "Creating desktop shortcut..."
        mkdir -p "$HOME/.local/share/applications"
        cat > "$HOME/.local/share/applications/romm-sync.desktop" << 'DESKTOPEOF'
[Desktop Entry]
Name=RomM Sync
Comment=Sync ROM metadata and files from RomM server
Exec=/home/deck/romm-sync/steam-launcher.sh
Icon=folder-download
Terminal=false
Type=Application
Categories=Game;Utility;
StartupNotify=false
DESKTOPEOF
        chmod +x "$HOME/.local/share/applications/romm-sync.desktop"
        print_success "Created desktop shortcut"
        
        # Try to add to Steam using steamos-add-to-steam if available
        if command -v steamos-add-to-steam &> /dev/null; then
            print_status "Adding to Steam library..."
            if steamos-add-to-steam "$HOME/.local/share/applications/romm-sync.desktop" 2>/dev/null; then
                print_success "Added to Steam (restart Steam to see it)"
            else
                print_warning "Failed to add to Steam automatically"
                echo ""
                echo "To add RomM Sync to Steam manually:"
                echo "  1. Switch to Desktop Mode"
                echo "  2. Open Steam"
                echo "  3. Games → Add a Non-Steam Game"
                echo "  4. Browse and select: $HOME/romm-sync/steam-launcher.sh"
                echo "  5. Right-click the game → Properties → Set name to 'RomM Sync'"
            fi
        else
            print_warning "steamos-add-to-steam not found"
            echo ""
            echo "To add RomM Sync to Steam manually:"
            echo "  1. Switch to Desktop Mode"
            echo "  2. Open Steam"
            echo "  3. Games → Add a Non-Steam Game"
            echo "  4. Browse and select: $HOME/romm-sync/steam-launcher.sh"
            echo "  5. Right-click the game → Properties → Set name to 'RomM Sync'"
        fi
        
        print_success "SteamDeck setup complete"
        echo ""
        echo "Next steps:"
        echo "  1. Edit ~/.config/romm-sync/config.example with your RomM server details"
        echo "  2. Rename it to 'config' (mv ~/.config/romm-sync/config.example ~/.config/romm-sync/config)"
        echo "  3. Launch 'RomM Sync' from Steam or Desktop Mode"
        echo "  4. Or run from terminal: romm-sync --target steamdeck -s https://your-server.com -u admin -p password"
        echo ""
        echo "The RomM Sync shortcut is available:"
        echo "  • Desktop Mode: Applications menu"
        echo "  • Gaming Mode: Steam library (after restart)"
        ;;
        
    generic)
        print_success "Generic Linux setup complete"
        echo ""
        echo "Next steps:"
        echo "  1. Edit ~/.config/romm-sync/config.example with your RomM server details"
        echo "  2. Rename it to 'config'"
        echo "  3. Run: romm-sync --help to see all options"
        echo "  4. Run: romm-sync -s https://your-server.com -u admin -p password"
        ;;
esac

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}  Installation Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Installed commands:"
echo "  • romm-sync           - Main command"

if [ "$SYSTEM_TYPE" = "retropie" ]; then
    echo "  • romm-sync-retropie  - RetroPie preset"
fi

if [ "$SYSTEM_TYPE" = "steamdeck" ]; then
    echo "  • romm-sync-steamdeck - SteamDeck preset"
fi

echo ""
echo "Configuration:"
echo "  • Config directory: $CONFIG_DIR"
echo "  • Example config:   $CONFIG_DIR/config.example"
echo ""
echo "Quick start:"
echo "  romm-sync -s https://your-romm-server.com -u admin -p password"
echo ""
echo "For more information:"
echo "  • Run: romm-sync --help"
echo "  • Read: README.md"
echo ""
