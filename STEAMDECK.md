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

### Auto-Detection (EmuDeck Users)
If you have EmuDeck installed, ROM paths are detected automatically. No configuration needed!

### Manual Path Configuration

**Internal Storage (Default):**
- ROMs: `~/Emulation/roms/`
- Metadata: `~/.emulationstation/gamelists/`
- Images: `~/.emulationstation/downloaded_media/`

**SD Card:**
If your ROMs are on an SD card, specify the path:
```bash
~/romm-sync/romm-sync -s https://your-server.com -u admin -p password --target steamdeck --rom-path /run/media/mmcblk0p1/Emulation
```

Common SD card paths:
- `/run/media/mmcblk0p1/Emulation/`
- `/run/media/deck/SDCARD/Emulation/`

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
ls ~/.emulationstation/gamelists/*/gamelist.xml

# Check if images were downloaded
ls ~/.emulationstation/downloaded_media/snes/covers/
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

### SD Card Not Detected

**Find your SD card path:**
```bash
ls /run/media/
```

Then use the full path:
```bash
--rom-path /run/media/YOUR-SD-CARD-NAME/Emulation
```

### Permission Errors

```bash
# Create directories if they don't exist
mkdir -p ~/Emulation/roms
mkdir -p ~/.emulationstation/gamelists
mkdir -p ~/.emulationstation/downloaded_media
```

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
3. Check ES-DE logs: `~/.emulationstation/es_log.txt`
4. Open an issue on GitHub with your error message
