#!/bin/bash
# Steam Overlay Launcher for RomM Sync
# This script provides a simple menu interface for syncing ROMs from Steam's overlay

# Change to script directory and activate venv
cd ~/romm-sync
source venv/bin/activate

# Load configuration
if [ -f "$HOME/.config/romm-sync/config" ]; then
    source "$HOME/.config/romm-sync/config"
else
    zenity --error --text="Configuration not found!\n\nPlease create ~/.config/romm-sync/config\nSee ~/.config/romm-sync/config.example for template"
    deactivate
    exit 1
fi

# Show menu using zenity
choice=$(zenity --list --title="RomM Sync" \
    --text="Select sync option:" \
    --column="Option" \
    "Sync Favorites (Metadata + Images)" \
    "Sync Favorites + Download ROMs" \
    --height=250 --width=400)

case "$choice" in
    "Sync Favorites (Metadata + Images)")
        # Show output in real-time text window
        ~/romm-sync/romm-sync -s "$ROMM_SERVER" -u "$ROMM_USER" -p "$ROMM_PASSWORD" --target steamdeck 2>&1 | \
            zenity --text-info --title="RomM Sync - Syncing Favorites" --width=900 --height=700 --auto-scroll
        ;;
    "Sync Favorites + Download ROMs")
        # Show output in real-time text window
        ~/romm-sync/romm-sync -s "$ROMM_SERVER" -u "$ROMM_USER" -p "$ROMM_PASSWORD" --target steamdeck --download-roms 2>&1 | \
            zenity --text-info --title="RomM Sync - Syncing Favorites + Downloading ROMs" --width=900 --height=700 --auto-scroll
        ;;
    *)
        deactivate
        exit 0
        ;;
esac

deactivate
