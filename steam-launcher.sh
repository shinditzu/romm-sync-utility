#!/bin/bash
# Steam Overlay Launcher for RomM Sync
# This script provides a simple menu interface for syncing ROMs from Steam's overlay

# Change to script directory
cd ~/romm-sync

# Activate virtual environment
source venv/bin/activate

# Configuration (edit these values)
ROMM_SERVER="https://your-romm-server.com"
ROMM_USER="your-username"
ROMM_PASSWORD="your-password"

# Show menu using zenity (KDE's dialog tool)
choice=$(zenity --list --title="RomM Sync" \
    --text="Select sync option:" \
    --column="Option" \
    "Sync Favorites (Metadata + Images)" \
    "Sync Favorites + Download ROMs" \
    "Sync All ROMs (Large!)" \
    --height=300 --width=400)

case "$choice" in
    "Sync Favorites (Metadata + Images)")
        zenity --info --text="Starting sync...\nThis may take a few minutes." --timeout=3
        ~/romm-sync/romm-sync -s "$ROMM_SERVER" -u "$ROMM_USER" -p "$ROMM_PASSWORD" --target steamdeck 2>&1 | \
            zenity --progress --pulsate --auto-close --text="Syncing metadata and images..."
        zenity --info --text="Sync complete!\n\nRestart ES-DE to see changes."
        ;;
    "Sync Favorites + Download ROMs")
        zenity --info --text="Starting sync with ROM downloads...\nThis may take a while." --timeout=3
        ~/romm-sync/romm-sync -s "$ROMM_SERVER" -u "$ROMM_USER" -p "$ROMM_PASSWORD" --target steamdeck --download-roms 2>&1 | \
            zenity --progress --pulsate --auto-close --text="Syncing and downloading ROMs..."
        zenity --info --text="Sync complete!\n\nRestart ES-DE to see changes."
        ;;
    "Sync All ROMs (Large!)")
        zenity --question --text="This will sync ALL ROMs, not just favorites.\n\nThis could take a very long time and use a lot of storage.\n\nContinue?"
        if [ $? -eq 0 ]; then
            zenity --info --text="Starting full sync...\nThis will take a long time." --timeout=3
            ~/romm-sync/romm-sync -s "$ROMM_SERVER" -u "$ROMM_USER" -p "$ROMM_PASSWORD" --target steamdeck --all-roms --download-roms 2>&1 | \
                zenity --progress --pulsate --auto-close --text="Syncing all ROMs..."
            zenity --info --text="Sync complete!\n\nRestart ES-DE to see changes."
        fi
        ;;
    *)
        exit 0
        ;;
esac

deactivate
