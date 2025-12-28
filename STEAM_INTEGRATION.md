# Steam Overlay Integration

This guide shows how to run RomM Sync directly from Steam's overlay on your SteamDeck.

## Setup

### 1. Edit the launcher script

First, edit `~/romm-sync/steam-launcher.sh` with your RomM server details:

```bash
nano ~/romm-sync/steam-launcher.sh
```

Update these lines:
```bash
ROMM_SERVER="https://your-romm-server.com"
ROMM_USER="your-username"
ROMM_PASSWORD="your-password"
```

Save and exit (Ctrl+X, Y, Enter).

### 2. Add to Steam as Non-Steam Game

**In Desktop Mode:**

1. Open Steam
2. Click **Games** → **Add a Non-Steam Game to My Library**
3. Click **Browse...**
4. Navigate to `/home/deck/romm-sync/`
5. Select `steam-launcher.sh`
6. Click **Add Selected Programs**

### 3. Rename and Configure (Optional)

1. Right-click the new entry in your Steam library
2. Select **Properties**
3. Change the name to "RomM Sync" or "Sync ROMs"
4. (Optional) Add custom artwork from SteamGridDB

### 4. Use from Gaming Mode

1. Switch to Gaming Mode
2. Find "RomM Sync" in your library (under "Non-Steam" category)
3. Launch it
4. Select your sync option from the menu
5. Wait for completion
6. Restart ES-DE to see your synced games

## Menu Options

The launcher provides three options:

1. **Sync Favorites (Metadata + Images)** - Fast, only syncs metadata and cover art
2. **Sync Favorites + Download ROMs** - Downloads ROM files for favorited games
3. **Sync All ROMs (Large!)** - Downloads ALL ROMs (warning: can be hundreds of GB)

## Troubleshooting

### Launcher doesn't appear in Steam
- Make sure `steam-launcher.sh` is executable: `chmod +x ~/romm-sync/steam-launcher.sh`
- Try adding it again from Desktop Mode

### Menu doesn't show up
- Install zenity: `flatpak install flathub org.gnome.Zenity` (in Desktop Mode)
- Or use konsole instead (KDE's terminal is always available)

### Sync fails
- Check your credentials in `steam-launcher.sh`
- Verify you can reach your RomM server
- Check logs at `/tmp/romm-sync.log`

## Alternative: Use Steam Deck's Quick Access Menu

You can also add the script to Steam's Quick Access menu using Decky Loader plugins like "SteamDeck Homebrew" if you have them installed.

## Notes

- The script uses `zenity` for dialog boxes (built into SteamOS)
- Auto-detects your ROM path from EmuDeck settings
- Works in both Gaming Mode and Desktop Mode
- Syncs to your SD card if that's where your ROMs are stored
