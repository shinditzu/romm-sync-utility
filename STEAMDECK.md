# SteamDeck Setup Guide

Sync your RomM library to SteamDeck's EmulationStation (ES-DE) with metadata, cover art, and ROM files.

## ⚡ Quick Install (3 Steps)

### 1. Switch to Desktop Mode
Press **Steam button** → **Power** → **Switch to Desktop**

### 2. Open Konsole (Terminal)
Click the **Application Launcher** (bottom left) → **System** → **Konsole**

### 3. Run the Installer
Copy and paste this into the terminal:

```bash
git clone https://github.com/shinditzu/romm-sync-utility.git
cd romm-sync-utility
./install.sh
```

**That's it!** The installer automatically:
- ✅ Creates a Python virtual environment
- ✅ Installs all dependencies
- ✅ Creates a GUI launcher
- ✅ Adds a desktop shortcut
- ✅ Attempts to add to your Steam library

---

## 🎮 First Time Setup

### Configure Your RomM Server

1. **Edit the config file:**
   ```bash
   nano ~/.config/romm-sync/config
   ```

2. **Add your RomM server details:**
   ```bash
   ROMM_SERVER=https://your-romm-server.com
   ROMM_USER=your-username
   ROMM_PASSWORD=your-password
   ```

3. **Save and exit:** Press `Ctrl+X`, then `Y`, then `Enter`

### Run Your First Sync

**Option A: Use the GUI (Easiest)**
- Find "RomM Sync" in your applications or Steam library
- Click it and select what you want to sync
- Progress will show in real-time!

**Option B: Use the Terminal**
```bash
~/romm-sync/romm-sync -s https://your-server.com -u admin -p password --target steamdeck
```

### View Your Games
1. Return to **Gaming Mode** (or stay in Desktop Mode)
2. Open **EmulationStation-DE**
3. Your synced games will appear with cover art and metadata!

---

## 📖 Usage Examples

### Sync Favorites Only (Default)
Only syncs ROMs you've marked as favorites in RomM:
```bash
~/romm-sync/romm-sync -s https://your-server.com -u admin -p password --target steamdeck
```

### Download ROM Files Too
Downloads actual ROM files along with metadata and images:
```bash
~/romm-sync/romm-sync -s https://your-server.com -u admin -p password --target steamdeck --download-roms
```

### Sync Specific Platforms
Only sync certain systems:
```bash
~/romm-sync/romm-sync -s https://your-server.com -u admin -p password --target steamdeck --platforms snes,gba,psx,n64
```

### Sync Everything (Warning: Large!)
Syncs your entire RomM library:
```bash
~/romm-sync/romm-sync -s https://your-server.com -u admin -p password --target steamdeck --all-roms
```

### Preview Changes (Dry Run)
See what would be synced without making changes:
```bash
~/romm-sync/romm-sync -s https://your-server.com -u admin -p password --target steamdeck --dry-run
```

---

## 💾 Storage Locations

### Automatic Path Detection
The script automatically detects your ES-DE configuration from `~/ES-DE/settings/es_settings.xml`:

- **ROMs**: Reads `ROMDirectory` setting (e.g., `/run/media/deck/.../Emulation/roms/`)
- **Images**: Reads `MediaDirectory` setting (e.g., `/run/media/deck/.../Emulation/tools/downloaded_media/`)
- **Gamelists**: Standard ES-DE location (`~/ES-DE/gamelists/{platform}/`)

**No configuration needed!** The script uses whatever paths ES-DE is already configured to use.

### Image Naming
Images are automatically named to match your ROM filenames for ES-DE compatibility:
- ROM: `Super Mario World (USA).sfc` → Image: `Super Mario World (USA).png`
- ROM: `abcop.zip` → Image: `abcop.png`

---

## 🎨 What Gets Synced

✅ **Game Metadata**
- Title, description, release date
- Genre, developer, publisher
- Player count (1-4 players)
- Kid-friendly flag (if in "Kid Friendly" collection)

✅ **Cover Art**
- High-quality box art from IGDB
- Automatically downloaded and organized
- Named to match ROM filenames for ES-DE compatibility

✅ **ROM Files** (Optional)
- Download actual game files from RomM
- Organized by platform
- Shows download progress with speed and file size

---

## ❓ Troubleshooting

### Games Don't Appear in ES-DE

**Solution 1: Restart ES-DE**
1. Close EmulationStation-DE completely
2. Reopen it from Gaming Mode or Desktop Mode
3. Wait for it to scan for games

**Solution 2: Check Files Were Created**
```bash
# Check if gamelist files exist
ls ~/ES-DE/gamelists/*/gamelist.xml

# Check if images were downloaded (path from your ES-DE settings)
ls /run/media/deck/*/Emulation/tools/downloaded_media/snes/covers/
```

**Solution 3: Verify Favorites in RomM**
- Log into your RomM web interface
- Make sure you have a "Favourites" collection
- Verify your games are actually in that collection
- Try syncing with `--all-roms` to test

### No Progress Shown During Sync

The sync now shows real-time progress! You should see:
- Platform being synced
- Number of favorites found
- Image download progress (X/Y)
- ROM download progress with file size and speed

If you don't see progress, make sure you're using the latest version:
```bash
cd ~/romm-sync-utility
git pull
./install.sh
```

### Connection Errors

**Check Network Access:**
```bash
# Test if you can reach your RomM server
curl https://your-romm-server.com
```

**Common Issues:**
- SteamDeck must be on the same network as RomM server (or have internet access if remote)
- Check firewall settings on your RomM server
- Verify username and password are correct

### ES-DE Settings Not Found

If the script can't find your ES-DE settings:
```bash
# Check if ES-DE settings exist
ls ~/ES-DE/settings/es_settings.xml
```

If the file doesn't exist, run ES-DE at least once to generate the configuration file.

---

## 🔄 Updating

To update to the latest version:

```bash
cd ~/romm-sync-utility
git pull
./install.sh
```

The installer will update everything automatically.

---

## 💡 Tips & Best Practices

### Start Small
- Sync favorites only at first (default behavior)
- Test with a few platforms: `--platforms snes,gba`
- Use `--dry-run` to preview changes

### Storage Management
- **Metadata + Images only**: ~1-5 MB per game
- **With ROM files**: Varies greatly by platform
  - SNES/NES: 1-4 MB per game
  - PS1: 200-700 MB per game
  - Wii: 1-8 GB per game

### Performance
- Sync shows real-time progress for downloads
- Images are rate-limited to avoid server overload
- Existing files are automatically skipped
- Safe to run multiple times

### Using the GUI
- The GUI launcher uses your config file automatically
- Progress is shown in a dialog window
- You'll get a notification when complete
- Can be launched from Steam overlay!

---

## 📝 Important Notes

- ✅ **Automatic path detection**: Reads paths from ES-DE configuration
- ✅ **ES-DE compatible naming**: Images match ROM filenames
- ✅ **Favorites by default**: Only syncs ROMs in your "Favourites" collection
- ✅ **Safe to re-run**: Skips existing files, won't duplicate
- ✅ **Network required**: Must have access to your RomM server
- ⚠️ **Storage space**: Be careful with `--download-roms --all-roms` (can be 100+ GB)
- ⚠️ **Restart ES-DE**: Games won't appear until you restart EmulationStation

---

## 🆘 Need Help?

If you're still having issues:
1. Check the troubleshooting section above
2. Run with `--dry-run` to see what would happen
3. Verify ES-DE settings exist: `~/ES-DE/settings/es_settings.xml`
4. Check ES-DE logs: `~/ES-DE/logs/` (or `~/.emulationstation/es_log.txt`)
5. Open an issue on GitHub with your error message
