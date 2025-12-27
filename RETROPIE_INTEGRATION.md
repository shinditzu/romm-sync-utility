# RetroPie Integration Guide

This guide explains how to run the RomM sync script directly from your RetroPie system.

## Prerequisites

1. SSH access to your RetroPie
2. Python 3 installed (usually pre-installed on RetroPie)
3. `requests` Python library installed

## Installation

### 1. Install Python Dependencies

SSH into your RetroPie and run:

```bash
sudo apt-get update
sudo apt-get install python3-pip
pip3 install requests
```

### 2. Copy Files to RetroPie

Copy the sync script files to your RetroPie. You can use SCP or copy them via the network share:

```bash
# Create directory for the script
mkdir -p ~/romm-sync

# Copy files (from your local machine)
scp romm_sync.py sync-romm.sh pi@retropie:~/romm-sync/

# Or if using network shares, copy to:
# \\RETROPIE\home\pi\romm-sync\
```

### 3. Configure Your RomM Credentials

Create a `.romm-config` file with your RomM server credentials:

```bash
cat > ~/romm-sync/.romm-config << 'EOF'
ROMM_SERVER="https://your-romm-server.com"
ROMM_USER="your-username"
ROMM_PASSWORD="your-password"
EOF

chmod 600 ~/romm-sync/.romm-config
```

**Security Note:** The `.romm-config` file contains your password. The `chmod 600` command ensures only you can read it.

### 4. Make Script Executable

```bash
chmod +x ~/romm-sync/sync-romm.sh
```

## Running the Sync

### Option 1: SSH Command Line (Simplest)

Just SSH into your RetroPie and run:

```bash
~/romm-sync/sync-romm.sh
```

You'll get an interactive menu to choose your sync mode.

### Option 2: Add to RetroPie Configuration Menu (Recommended)

This adds the sync script to the RetroPie menu (the one you access from EmulationStation's main menu).

1. Create a custom runcommand script:

```bash
sudo mkdir -p ~/RetroPie/retropiemenu
cat > ~/RetroPie/retropiemenu/romm-sync.sh << 'EOF'
#!/bin/bash
# Resolve home directory dynamically
SCRIPT_DIR="${HOME}/romm-sync"
"${SCRIPT_DIR}/sync-romm.sh"
EOF

sudo chmod +x ~/RetroPie/retropiemenu/romm-sync.sh
```

2. Create a gamelist entry so it shows up with a nice name:

```bash
cat > ~/RetroPie/retropiemenu/gamelist.xml << 'EOF'
<?xml version="1.0"?>
<gameList>
  <game>
    <path>./romm-sync.sh</path>
    <name>RomM Sync</name>
    <desc>Sync ROM metadata and files from RomM server</desc>
  </game>
</gameList>
EOF
```

3. Restart EmulationStation

4. Navigate to **RetroPie** in EmulationStation's main menu and you'll see "RomM Sync"

5. Launch it to see the interactive menu!

### Menu Features

The script provides a RetroPie-style dialog menu with these options:

1. **Sync Favorites (Metadata + Images)** - Quick sync of favorite ROMs
2. **Sync Favorites + Download ROMs** - Download ROM files for favorites
3. **Dry Run (Preview Changes)** - See what would be synced without making changes
4. **Select Specific Platforms** - Choose which platforms to sync with checkboxes
5. **View Sync Status** - View the last sync log
6. **Configuration** - View current server settings
7. **Exit** - Return to EmulationStation

The menu includes:
- ✅ Live output during sync operations
- ✅ Progress indicators
- ✅ Success/error notifications
- ✅ Confirmation dialogs for destructive operations
- ✅ Log viewing capability
- ✅ Platform selection with checkboxes

### Option 3: Add to EmulationStation Ports Menu (Alternative)

This adds the sync script as a "game" in the Ports section of EmulationStation.

1. Create a shell script launcher:

```bash
cat > ~/RetroPie/roms/ports/RomM-Sync.sh << 'EOF'
#!/bin/bash
~/romm-sync/sync-romm.sh
EOF

chmod +x ~/RetroPie/roms/ports/RomM-Sync.sh
```

2. Restart EmulationStation

3. Navigate to **Ports** in EmulationStation and you'll see "RomM-Sync"

4. Launch it to run the sync from the EmulationStation interface!

### Option 4: Add to RetroPie-Setup Menu (Advanced)

Create a custom RetroPie-Setup scriptmodule:

1. Create the scriptmodule:

```bash
sudo nano /home/pi/RetroPie-Setup/scriptmodules/supplementary/romm-sync.sh
```

2. Add this content:

```bash
#!/usr/bin/env bash

rp_module_id="romm-sync"
rp_module_desc="RomM to RetroPie Metadata Sync"
rp_module_section="config"

function gui_romm-sync() {
    ~/romm-sync/sync-romm.sh
}
```

3. Make it executable:

```bash
sudo chmod +x /home/pi/RetroPie-Setup/scriptmodules/supplementary/romm-sync.sh
```

4. Access it from: **RetroPie-Setup → Configuration/Tools → romm-sync**

### Option 4: Cron Job (Automatic Sync)

To automatically sync on a schedule:

```bash
crontab -e
```

Add one of these lines:

```bash
# Sync favorites daily at 3 AM
0 3 * * * /home/pi/romm-sync/sync-romm.sh <<< "1" > /dev/null 2>&1

# Sync favorites every 6 hours
0 */6 * * * /home/pi/romm-sync/sync-romm.sh <<< "1" > /dev/null 2>&1
```

## Quick Sync Commands

For direct command-line use without the menu:

```bash
# Sync favorites only
cd ~/romm-sync && python3 romm_sync.py -s https://your-server.com -u user -p pass

# Sync favorites + download ROMs
cd ~/romm-sync && python3 romm_sync.py -s https://your-server.com -u user -p pass --download-roms

# Dry run
cd ~/romm-sync && python3 romm_sync.py -s https://your-server.com -u user -p pass --dry-run

# Sync specific platforms
cd ~/romm-sync && python3 romm_sync.py -s https://your-server.com -u user -p pass --platforms snes,nes,gba
```

## Troubleshooting

### Script not found
Make sure you're in the right directory or use the full path:
```bash
/home/pi/romm-sync/sync-romm.sh
```

### Permission denied
Make the script executable:
```bash
chmod +x ~/romm-sync/sync-romm.sh
```

### Python module not found
Install requests:
```bash
pip3 install requests
```

### EmulationStation doesn't show changes
After syncing, restart EmulationStation:
```bash
# Press F4 to exit to terminal, then:
emulationstation
```

Or reboot:
```bash
sudo reboot
```

## Security Best Practices

Your RomM credentials are stored in `~/.romm-config`:

1. **File permissions** are set to `600` (only you can read/write)
2. **Keep the file secure** - don't share it or commit it to version control
3. **Alternative: Environment variables** - You can also set these in your shell profile:
```bash
export ROMM_SERVER="https://your-server.com"
export ROMM_USER="your-user"
export ROMM_PASSWORD="your-password"
```

The script will use environment variables if they're set, otherwise it falls back to the config file.

## Recommended Workflow

1. **Initial Setup**: Run with `--download-roms` to download all your favorite ROMs
2. **Regular Updates**: Run without `--download-roms` to just update metadata and new images
3. **After Adding Favorites**: Run the sync to pull new favorites from RomM
4. **Kid-Friendly Updates**: Add/remove games from "Kid Friendly" collection in RomM, then sync

## What Gets Updated

- ✅ Game metadata (name, description, ratings, etc.)
- ✅ Cover images
- ✅ Kid-friendly flags
- ✅ ROM files (if `--download-roms` is used)
- ✅ Gamelist.xml files for EmulationStation

## What Doesn't Get Updated

- ❌ Existing ROM files (won't re-download)
- ❌ Existing images (won't re-download)
- ❌ Your game saves or save states
- ❌ EmulationStation settings
