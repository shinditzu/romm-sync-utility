# SteamDeck (ES-DE) Setup Guide

This guide covers using the RomM sync script with EmulationStation Desktop Edition (ES-DE) on SteamDeck.

## Quick Start

```bash
# Sync favorites to SteamDeck
python3 romm_sync.py -s https://your-romm-server.com -u admin -p password --target steamdeck

# Sync specific platforms
python3 romm_sync.py -s https://your-romm-server.com -u admin -p password --target steamdeck --platforms snes,gba,psx

# Download ROM files too
python3 romm_sync.py -s https://your-romm-server.com -u admin -p password --target steamdeck --download-roms
```

## SteamDeck Paths

When using `--target steamdeck`, the script uses ES-DE standard paths:

- **ROMs**: `~/Emulation/roms/{platform}/`
- **Gamelists**: `~/.emulationstation/gamelists/{platform}/gamelist.xml`
- **Cover Images**: `~/.emulationstation/downloaded_media/{platform}/covers/`

## Installation on SteamDeck

### 1. Switch to Desktop Mode
Press the Steam button → Power → Switch to Desktop

### 2. Install Python (if not already installed)
```bash
# Check if Python is installed
python3 --version

# If not installed, use Discover (KDE app store) or:
sudo pacman -S python python-pip
```

### 3. Install requests library
```bash
pip install --user requests
```

### 4. Download the script
```bash
# Create directory
mkdir -p ~/romm-sync
cd ~/romm-sync

# Download script (replace with your method)
# Option 1: Use git
git clone https://github.com/shinditzu/romm-to-retropie.git .

# Option 2: Download directly
curl -O https://raw.githubusercontent.com/yourusername/romm-to-retropie/main/romm_sync.py
```

### 5. Create config file (optional)
```bash
cat > ~/.romm-config << EOF
ROMM_SERVER=https://your-romm-server.com
ROMM_USER=your-username
ROMM_PASSWORD=your-password
EOF
chmod 600 ~/.romm-config
```

## Usage

### Basic Sync (Favorites Only)
```bash
cd ~/romm-sync
python3 romm_sync.py -s https://your-server.com -u admin -p password --target steamdeck
```

### Sync All ROMs (Warning: Large!)
```bash
python3 romm_sync.py -s https://your-server.com -u admin -p password --target steamdeck --all-roms
```

### Download ROM Files
```bash
python3 romm_sync.py -s https://your-server.com -u admin -p password --target steamdeck --download-roms
```

### Dry Run (Preview Changes)
```bash
python3 romm_sync.py -s https://your-server.com -u admin -p password --target steamdeck --dry-run
```

## ES-DE Integration

After syncing, restart ES-DE to see your games:
1. Close ES-DE if running
2. Relaunch ES-DE from Gaming Mode or Desktop Mode
3. Your synced games should appear with metadata and cover art

## Differences from RetroPie

| Feature | RetroPie | SteamDeck (ES-DE) |
|---------|----------|-------------------|
| ROMs Path | `~/RetroPie/roms/` | `~/Emulation/roms/` |
| Images Path | `~/.emulationstation/downloaded_images/` | `~/.emulationstation/downloaded_media/{platform}/covers/` |
| Gamelist Path | `./.emulationstation/gamelists/` | `~/.emulationstation/gamelists/` |

## Troubleshooting

### Script can't find Python
```bash
# Use full path
/usr/bin/python3 romm_sync.py --target steamdeck ...
```

### Permission denied on directories
```bash
# Ensure directories exist and are writable
mkdir -p ~/Emulation/roms
mkdir -p ~/.emulationstation/gamelists
mkdir -p ~/.emulationstation/downloaded_media
```

### ES-DE doesn't show games
1. Verify gamelist.xml exists: `ls ~/.emulationstation/gamelists/*/gamelist.xml`
2. Check ROM files exist: `ls ~/Emulation/roms/`
3. Restart ES-DE completely
4. Check ES-DE logs: `~/.emulationstation/es_log.txt`

### Images not showing
- ES-DE looks for images in `downloaded_media/{platform}/covers/`
- Verify images exist: `ls ~/.emulationstation/downloaded_media/snes/covers/`
- Check image paths in gamelist.xml match actual file locations

## Automation

Create a script to run sync regularly:

```bash
#!/bin/bash
# ~/romm-sync/sync-steamdeck.sh

cd ~/romm-sync
python3 romm_sync.py \
  -s https://your-server.com \
  -u admin \
  -p password \
  --target steamdeck \
  --platforms snes,gba,psx,n64

echo "Sync complete! Restart ES-DE to see changes."
```

Make it executable:
```bash
chmod +x ~/romm-sync/sync-steamdeck.sh
```

## Notes

- **Favorites by default**: Only syncs ROMs marked as favorites in RomM (use `--all-roms` to sync everything)
- **Idempotent**: Safe to run multiple times, skips existing files
- **Network required**: Must have access to your RomM server
- **Storage space**: Be mindful when using `--download-roms --all-roms` as it can be hundreds of GB
