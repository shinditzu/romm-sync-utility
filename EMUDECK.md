# EmuDeck Setup Guide

This guide covers using the RomM sync script with EmuDeck on SteamDeck.

## Quick Start

```bash
# Find your Emulation path (usually on SD card)
ls -la /run/media/deck/*/Emulation

# Sync with your actual path
python3 romm_sync.py \
  -s https://your-romm-server.com \
  -u admin \
  -p password \
  --target emudeck \
  --rom-path /run/media/deck/YOUR-SDCARD-ID/Emulation
```

## Finding Your EmuDeck Path

EmuDeck typically installs to an SD card or external storage. The path usually looks like:
```
/run/media/deck/[UUID]/Emulation
```

To find your exact path:
```bash
# List all mounted storage
ls -la /run/media/deck/

# Find Emulation directory
find /run/media/deck -name "Emulation" -type d 2>/dev/null

# Or check EmuDeck's typical locations
ls -la /run/media/mmcblk0p1/Emulation  # SD card
ls -la ~/Emulation                      # Internal storage (rare)
```

Example paths:
- `/run/media/deck/ff4537d8-786f-4ea5-b05a-4c8472e43826/Emulation`
- `/run/media/mmcblk0p1/Emulation`

## EmuDeck Directory Structure

```
/run/media/deck/SDCARD/Emulation/
├── roms/
│   ├── snes/
│   ├── gba/
│   ├── psx/
│   └── ...
├── bios/
├── saves/
└── storage/
```

## Installation

### 1. Switch to Desktop Mode
Press Steam button → Power → Switch to Desktop

### 2. Open Konsole (Terminal)
Find it in the application menu or search for "Konsole"

### 3. Install Python dependencies
```bash
# Install requests library
pip install --user requests
```

### 4. Download the script
```bash
# Create directory
mkdir -p ~/romm-sync
cd ~/romm-sync

# Download script
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

## Usage Examples

### Sync Favorites Only (Recommended)
```bash
python3 romm_sync.py \
  -s https://your-server.com \
  -u admin \
  -p password \
  --target emudeck \
  --rom-path /run/media/deck/YOUR-UUID/Emulation
```

### Sync Specific Platforms
```bash
python3 romm_sync.py \
  -s https://your-server.com \
  -u admin \
  -p password \
  --target emudeck \
  --rom-path /run/media/deck/YOUR-UUID/Emulation \
  --platforms snes,gba,psx
```

### Download ROM Files
```bash
python3 romm_sync.py \
  -s https://your-server.com \
  -u admin \
  -p password \
  --target emudeck \
  --rom-path /run/media/deck/YOUR-UUID/Emulation \
  --download-roms
```

**Note:** ROM files will be downloaded to your SD card's Emulation/roms/{platform}/ directory.

### Dry Run (Preview Changes)
```bash
python3 romm_sync.py \
  -s https://your-server.com \
  -u admin \
  -p password \
  --target emudeck \
  --rom-path /run/media/deck/YOUR-UUID/Emulation \
  --dry-run
```

## What Gets Synced

### Gamelists
- **Location**: `~/.emulationstation/gamelists/{platform}/gamelist.xml`
- **Contains**: Game metadata (titles, descriptions, ratings, etc.)

### Cover Images
- **Location**: `~/.emulationstation/downloaded_media/{platform}/covers/`
- **Format**: PNG files named by ROM ID

### ROM Files (if --download-roms used)
- **Location**: `/run/media/deck/YOUR-UUID/Emulation/roms/{platform}/`
- **Note**: Downloads to your SD card, ensure you have enough space

## After Syncing

1. **Close EmulationStation** if it's running
2. **Restart EmulationStation** from Gaming Mode or Desktop Mode
3. Your synced games should appear with metadata and cover art

## Troubleshooting

### Error: "--target emudeck requires --rom-path"
You must specify where your Emulation directory is located:
```bash
# Find it first
ls -la /run/media/deck/*/Emulation

# Then use the full path
--rom-path /run/media/deck/YOUR-UUID/Emulation
```

### SD Card Not Mounted
```bash
# Check if SD card is mounted
df -h | grep mmcblk

# If not mounted, insert SD card and wait a few seconds
# Or manually mount it
```

### Games Not Showing in EmulationStation
1. Verify gamelist.xml exists:
   ```bash
   ls ~/.emulationstation/gamelists/*/gamelist.xml
   ```

2. Check ROM paths in gamelist.xml:
   ```bash
   grep "<path>" ~/.emulationstation/gamelists/snes/gamelist.xml | head -5
   ```
   Paths should match your actual ROM location.

3. Verify ROM files exist:
   ```bash
   ls /run/media/deck/YOUR-UUID/Emulation/roms/snes/
   ```

4. Check EmulationStation logs:
   ```bash
   tail -f ~/.emulationstation/es_log.txt
   ```

### Images Not Displaying
- ES-DE looks for covers in: `~/.emulationstation/downloaded_media/{platform}/covers/`
- Verify images exist:
  ```bash
  ls ~/.emulationstation/downloaded_media/snes/covers/
  ```
- Check image paths in gamelist.xml match actual locations

### Permission Issues
```bash
# Ensure directories are writable
chmod -R u+w ~/.emulationstation/
chmod -R u+w /run/media/deck/YOUR-UUID/Emulation/
```

### Out of Space on SD Card
```bash
# Check available space
df -h /run/media/deck/YOUR-UUID/

# If low, consider:
# 1. Only sync specific platforms (--platforms)
# 2. Only sync favorites (default behavior)
# 3. Skip ROM downloads (remove --download-roms flag)
```

## Automation Script

Create a helper script for easy syncing:

```bash
#!/bin/bash
# ~/romm-sync/sync-emudeck.sh

# Find Emulation path automatically
EMULATION_PATH=$(find /run/media/deck -name "Emulation" -type d 2>/dev/null | head -1)

if [ -z "$EMULATION_PATH" ]; then
    echo "Error: Could not find Emulation directory"
    echo "Is your SD card mounted?"
    exit 1
fi

echo "Found Emulation at: $EMULATION_PATH"

cd ~/romm-sync
python3 romm_sync.py \
  -s https://your-server.com \
  -u admin \
  -p password \
  --target emudeck \
  --rom-path "$EMULATION_PATH" \
  --platforms snes,gba,psx,n64

echo ""
echo "Sync complete! Restart EmulationStation to see changes."
```

Make it executable:
```bash
chmod +x ~/romm-sync/sync-emudeck.sh
```

Run it:
```bash
~/romm-sync/sync-emudeck.sh
```

## Notes

- **Favorites by default**: Only syncs ROMs marked as favorites in RomM
- **Use --all-roms carefully**: Can sync thousands of ROMs and fill your SD card
- **Idempotent**: Safe to run multiple times, skips existing files
- **Network required**: Must have access to your RomM server
- **SD card space**: Monitor available space when downloading ROMs
- **Absolute paths**: EmuDeck requires absolute ROM paths in gamelist.xml (handled automatically)
