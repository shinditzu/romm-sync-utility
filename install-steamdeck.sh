#!/bin/bash
# SteamDeck Installation Script for RomM Sync Utility

set -e

echo "=== RomM Sync Utility - SteamDeck Installer ==="
echo ""

# Create directory
echo "Creating ~/romm-sync directory..."
mkdir -p ~/romm-sync
cd ~/romm-sync

# Create virtual environment
echo "Creating Python virtual environment..."
python3 -m venv venv

# Activate and install dependencies
echo "Installing dependencies..."
source venv/bin/activate
pip install --upgrade pip
pip install requests

# Download script
echo "Downloading romm_sync.py..."
curl -O https://raw.githubusercontent.com/shinditzu/romm-sync-utility/main/romm_sync.py

# Create wrapper script
echo "Creating wrapper script..."
cat > ~/romm-sync/romm-sync << 'EOF'
#!/bin/bash
# Wrapper script that auto-activates venv
cd ~/romm-sync
source venv/bin/activate
python romm_sync.py "$@"
deactivate
EOF

chmod +x ~/romm-sync/romm-sync

echo ""
echo "=== Installation Complete! ==="
echo ""
echo "You can now run the script with:"
echo "  ~/romm-sync/romm-sync -s https://your-server.com -u admin -p password --target steamdeck"
echo ""
echo "Or add it to your PATH by adding this to ~/.bashrc:"
echo "  export PATH=\"\$HOME/romm-sync:\$PATH\""
echo ""
echo "Then you can just run: romm-sync --target steamdeck ..."
echo ""
