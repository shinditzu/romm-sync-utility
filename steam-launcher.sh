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
        zenity --info --text="Starting sync...\nThis may take a few minutes." --timeout=3
        (
            stdbuf -oL ~/romm-sync/romm-sync -s "$ROMM_SERVER" -u "$ROMM_USER" -p "$ROMM_PASSWORD" --target steamdeck 2>&1 | \
            while IFS= read -r line; do
                echo "# $line"
            done
        ) | zenity --progress --pulsate --auto-close --no-cancel
        zenity --info --text="Sync complete!\n\nRestart ES-DE to see changes."
        ;;
    "Sync Favorites + Download ROMs")
        zenity --info --text="Starting sync with ROM downloads...\nThis may take a while." --timeout=3
        (
            stdbuf -oL ~/romm-sync/romm-sync -s "$ROMM_SERVER" -u "$ROMM_USER" -p "$ROMM_PASSWORD" --target steamdeck --download-roms 2>&1 | \
            while IFS= read -r line; do
                echo "# $line"
            done
        ) | zenity --progress --pulsate --auto-close --no-cancel
        zenity --info --text="Sync complete!\n\nRestart ES-DE to see changes."
        ;;
    *)
        deactivate
        exit 0
        ;;
esac

deactivate
