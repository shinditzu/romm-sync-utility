#!/bin/bash
# RomM to RetroPie Sync Wrapper Script
# This script provides an easy way to sync ROM metadata from RomM to RetroPie

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load configuration from standardized config location
CONFIG_FILE="$HOME/.config/romm-sync/config"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    dialog --title "Configuration Error" --msgbox "Configuration not found!\n\nPlease create: ~/.config/romm-sync/config\n\nSee ~/.config/romm-sync/config.example for template" 10 60
    clear
    exit 1
fi

# Check if dialog is available
if ! command -v dialog &> /dev/null; then
    echo "Installing dialog for better UI..."
    sudo apt-get update && sudo apt-get install -y dialog
fi

# Check if Python script exists
if [ ! -f "$SCRIPT_DIR/romm_sync.py" ]; then
    dialog --title "Error" --msgbox "romm_sync.py not found in $SCRIPT_DIR" 8 60
    clear
    exit 1
fi

# Function to show main menu
show_main_menu() {
    choice=$(dialog --stdout --title "RomM to RetroPie Sync" \
        --backtitle "RomM Metadata and ROM Synchronization Tool" \
        --menu "Choose an option:" 18 70 10 \
        1 "Sync Favorites (Metadata + Images)" \
        2 "Sync Favorites + Download ROMs" \
        3 "Dry Run (Preview Changes)" \
        4 "Select Specific Platforms" \
        5 "View Sync Status" \
        6 "Configuration" \
        7 "Exit")
    
    return $?
}

# Function to run sync with progress
run_sync() {
    local args="$1"
    local description="$2"
    
    # Show info message
    dialog --title "Starting Sync" --infobox "$description\n\nPlease wait..." 6 60
    sleep 1
    
    # Clear the log file
    > /tmp/romm-sync.log
    
    # Run sync in background and show live tail
    python3 -u "$SCRIPT_DIR/romm_sync.py" \
        -s "$ROMM_SERVER" \
        -u "$ROMM_USER" \
        -p "$ROMM_PASSWORD" \
        $args >> /tmp/romm-sync.log 2>&1 &
    
    local sync_pid=$!
    
    # Give the Python script a moment to start writing
    sleep 0.5
    
    # Show live scrolling output
    tail -f /tmp/romm-sync.log 2>/dev/null | \
        dialog --title "Syncing..." --programbox 30 100 &
    
    local dialog_pid=$!
    
    # Get the tail PID (it's the parent of the dialog in the pipeline)
    local tail_pid=$(jobs -p | grep -v $sync_pid)
    
    # Wait for sync to complete
    wait $sync_pid
    local exit_code=$?
    
    # Kill the tail and dialog processes
    kill $dialog_pid 2>/dev/null
    kill $tail_pid 2>/dev/null
    pkill -P $$ tail 2>/dev/null
    wait $dialog_pid 2>/dev/null
    wait $tail_pid 2>/dev/null
    
    # Show completion message
    if [ $exit_code -eq 0 ]; then
        dialog --title "Success" --yesno "Sync completed successfully!\n\nLog saved to: /tmp/romm-sync.log\n\nRestart EmulationStation now to see changes?" 12 60
        if [ $? -eq 0 ]; then
            clear
            echo "Restarting EmulationStation..."
            killall emulationstation
            sleep 1
            emulationstation &
            exit 0
        fi
    else
        dialog --title "Error" --msgbox "Sync failed with error code: $exit_code\n\nCheck /tmp/romm-sync.log for details." 10 60
    fi
}

# Function to select platforms
select_platforms() {
    local platforms=$(dialog --stdout --title "Select Platforms" \
        --backtitle "Choose which platforms to sync" \
        --checklist "Select platforms (Space to toggle, Enter to confirm):" 20 70 12 \
        "nes" "Nintendo Entertainment System" off \
        "snes" "Super Nintendo" off \
        "n64" "Nintendo 64" off \
        "gba" "Game Boy Advance" off \
        "gbc" "Game Boy Color" off \
        "nds" "Nintendo DS" off \
        "genesis" "Sega Genesis" off \
        "psx" "PlayStation" off \
        "psp" "PlayStation Portable" off \
        "arcade" "Arcade" off \
        "gamecube" "GameCube" off \
        "wii" "Wii" off)
    
    if [ $? -eq 0 ] && [ -n "$platforms" ]; then
        # Convert to comma-separated list
        local platform_list=$(echo $platforms | tr ' ' ',' | tr -d '"')
        
        dialog --title "Confirm" --yesno "Sync these platforms?\n\n$platform_list" 10 60
        if [ $? -eq 0 ]; then
            run_sync "-o ${HOME}/.emulationstation/gamelists --platforms $platform_list" "Syncing selected platforms..."
        fi
    fi
}

# Function to show configuration
show_config() {
    dialog --title "Current Configuration" --msgbox "Server: $ROMM_SERVER\nUser: $ROMM_USER\n\nTo change settings, edit:\n~/.config/romm-sync/config" 12 60
}

# Function to view sync status
view_status() {
    if [ -f /tmp/romm-sync.log ]; then
        dialog --title "Last Sync Log" --textbox /tmp/romm-sync.log 30 100
    else
        dialog --title "No Log Found" --msgbox "No previous sync log found.\n\nRun a sync first to generate a log." 8 50
    fi
}

# Main loop
while true; do
    show_main_menu
    menu_result=$?
    
    # Exit if cancelled
    if [ $menu_result -ne 0 ]; then
        clear
        exit 0
    fi

    case $choice in
        1)
            run_sync "-o ${HOME}/.emulationstation/gamelists" "Syncing favorite ROMs (metadata + images)"
            ;;
        2)
            run_sync "-o ${HOME}/.emulationstation/gamelists --download-roms" "Syncing favorite ROMs + downloading files"
            ;;
        3)
            run_sync "-o ${HOME}/.emulationstation/gamelists --dry-run" "Running dry run (preview mode)"
            ;;
        4)
            select_platforms
            ;;
        5)
            view_status
            ;;
        6)
            show_config
            ;;
        7)
            clear
            exit 0
            ;;
    esac
done
