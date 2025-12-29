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

- **ROMs**: `~/Emulation/roms/{platform}/` (internal storage) or custom path for SD card
- **Gamelists**: `~/.emulationstation/gamelists/{platform}/gamelist.xml`
- **Cover Images**: `~/.emulationstation/downloaded_media/{platform}/covers/`

### ROM Path Detection

**Auto-Detection (EmuDeck users):**
If you have EmuDeck installed, the script will automatically detect your ROM path from `~/emudeck/settings.sh`. No need to specify `--rom-path`!

**Manual Detection:**

**Internal Storage (default):**
```bash
~/Emulation/roms/
```

**SD Card:**
```bash
# Find your SD card mount point
ls -la /run/media/mmcblk0p1/Emulation/

# Common SD card paths:
# /run/media/mmcblk0p1/Emulation/roms/
# /run/media/deck/SDCARD/Emulation/roms/
```

**Override Auto-Detection:**
Use `--rom-path` to manually specify your Emulation directory:
```bash
--rom-path /run/media/mmcblk0p1/Emulation
```

## Installation on SteamDeck

### Quick Install (Recommended)

1. **Switch to Desktop Mode**: Press Steam button → Power → Switch to Desktop

2. **Run the universal installer**:
```bash
git clone https://github.com/shinditzu/romm-sync-utility.git
cd romm-sync-utility
./install.sh
```

The installer will automatically detect SteamDeck and:
- Create `~/romm-sync` directory with Python virtual environment
- Install dependencies (requests library)
- Copy romm_sync.py and create wrapper scripts
- Create Steam launcher with GUI menu (zenity)
- Create desktop shortcut
- Attempt to add to Steam library automatically
- Create example configuration file

3. **Run the sync**:
```bash
~/romm-sync/romm-sync -s https://your-server.com -u admin -p password --target steamdeck
```

### Manual Installation (Alternative)

If you prefer to install manually:

```bash
# Create directory and virtual environment
mkdir -p ~/romm-sync
cd ~/romm-sync
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install requests

# Download script
curl -O https://raw.githubusercontent.com/shinditzu/romm-sync-utility/main/romm_sync.py

# Create wrapper script
cat > ~/romm-sync/romm-sync << 'EOF'
#!/bin/bash
cd ~/romm-sync
source venv/bin/activate
python romm_sync.py "$@"
deactivate
EOF

chmod +x ~/romm-sync/romm-sync
```

### Optional: Add to PATH

To run `romm-sync` from anywhere:
```bash
echo 'export PATH="$HOME/romm-sync:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Then you can simply run:
```bash
romm-sync -s https://your-server.com -u admin -p password --target steamdeck
```

## Usage

If you used the installer, use the wrapper script (handles venv automatically):

### Basic Sync (Favorites Only)

**With EmuDeck (auto-detects ROM path):**
```bash
~/romm-sync/romm-sync -s https://your-server.com -u admin -p password --target steamdeck
```

**Without EmuDeck or Custom Path:**
```bash
~/romm-sync/romm-sync -s https://your-server.com -u admin -p password --target steamdeck --rom-path /run/media/mmcblk0p1/Emulation
```

### Sync All ROMs (Warning: Large!)
```bash
~/romm-sync/romm-sync -s https://your-server.com -u admin -p password --target steamdeck --all-roms
```

### Download ROM Files

**To Internal Storage:**
```bash
~/romm-sync/romm-sync -s https://your-server.com -u admin -p password --target steamdeck --download-roms
```

**To SD Card:**
```bash
~/romm-sync/romm-sync -s https://your-server.com -u admin -p password --target steamdeck --download-roms --rom-path /run/media/mmcblk0p1/Emulation
```

### Dry Run (Preview Changes)
```bash
~/romm-sync/romm-sync -s https://your-server.com -u admin -p password --target steamdeck --dry-run
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
