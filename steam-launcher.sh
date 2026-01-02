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
        # Run sync and capture output
        output=$(mktemp)
        ~/romm-sync/romm-sync -s "$ROMM_SERVER" -u "$ROMM_USER" -p "$ROMM_PASSWORD" --target steamdeck 2>&1 | tee "$output" | \
            zenity --progress --pulsate --title="RomM Sync" --text="Syncing favorites..." --auto-close --no-cancel &
        
        # Wait for sync to complete
        wait
        
        # Show detailed results
        zenity --text-info --title="RomM Sync - Complete" --filename="$output" --width=800 --height=600
        rm -f "$output"
        ;;
    "Sync Favorites + Download ROMs")
        # Run sync and capture output
        output=$(mktemp)
        ~/romm-sync/romm-sync -s "$ROMM_SERVER" -u "$ROMM_USER" -p "$ROMM_PASSWORD" --target steamdeck --download-roms 2>&1 | tee "$output" | \
            zenity --progress --pulsate --title="RomM Sync" --text="Syncing favorites and downloading ROMs..." --auto-close --no-cancel &
        
        # Wait for sync to complete
        wait
        
        # Show detailed results
        zenity --text-info --title="RomM Sync - Complete" --filename="$output" --width=800 --height=600
        rm -f "$output"
        ;;
    *)
        deactivate
        exit 0
        ;;
esac

deactivate
