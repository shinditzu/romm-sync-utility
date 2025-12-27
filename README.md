# RomM to EmulationStation Sync

Syncs ROM metadata from a [RomM](https://github.com/rommapp/romm) server to EmulationStation `gamelist.xml` format.

**Supports:**
- **RetroPie** - Raspberry Pi retro gaming distribution
- **SteamDeck (ES-DE)** - EmulationStation Desktop Edition on SteamDeck
- **EmuDeck** - SteamDeck with EmuDeck on external storage
- Custom configurations via CLI flags

## Features

- **Multi-target support** - RetroPie, SteamDeck (ES-DE), or custom paths
- **Syncs favorites by default** - prevents accidental full library syncs
- **Automatic cleanup** - removes ROMs and images when games are unfavorited
- **Download ROM files** - optionally download actual ROM files from RomM server
- Pulls metadata from RomM API (titles, descriptions, ratings, release dates, genres, etc.)
- Downloads cover images from RomM or external sources (IGDB)
- Generates EmulationStation-compatible `gamelist.xml` files
- Maps 40+ platform slugs to EmulationStation folder names
- Retry logic with exponential backoff for network requests
- Dry-run mode for testing

## Requirements

- Python 3.7+
- `requests` library

```bash
pip install requests
```

## Running from RetroPie

See **[RETROPIE_INTEGRATION.md](RETROPIE_INTEGRATION.md)** for detailed instructions on:
- Running the sync from EmulationStation's Ports menu
- Adding to RetroPie-Setup menu
- Setting up automatic syncs with cron
- SSH command-line usage

**Quick Start for RetroPie:**
```bash
# Copy files to RetroPie
scp romm_sync.py sync-romm.sh pi@retropie:~/romm-sync/

# SSH into RetroPie and run
chmod +x ~/romm-sync/sync-romm.sh
~/romm-sync/sync-romm.sh
```

## Usage

### Basic sync (RetroPie - favorites only, all platforms)
```bash
python3 romm_sync.py -s https://your-romm-server.com -u admin -p password
```
**Note:** By default, only ROMs marked as favorites in RomM are synced. Use `--all-roms` to sync your entire library.

### SteamDeck (ES-DE) sync
```bash
python3 romm_sync.py -s https://your-romm-server.com -u admin -p password --target steamdeck
```
This uses ES-DE paths:
- ROMs: `~/Emulation/roms/{platform}/`
- Gamelists: `~/.emulationstation/gamelists/{platform}/`
- Images: `~/.emulationstation/downloaded_media/{platform}/covers/`

### EmuDeck (SteamDeck with external storage)
```bash
# First, find your Emulation path
ls -la /run/media/deck/*/Emulation

# Then sync with your actual path
python3 romm_sync.py -s https://your-romm-server.com -u admin -p password \
  --target emudeck \
  --rom-path /run/media/deck/YOUR-SDCARD-ID/Emulation
```
EmuDeck typically installs ROMs on SD card or external storage. The `--rom-path` is **required** for EmuDeck target.

### Sync specific platforms
```bash
python3 romm_sync.py -s https://your-romm-server.com -u admin -p password --platforms snes,nes,gba
```

### List available platforms
```bash
python3 romm_sync.py -s https://your-romm-server.com -u admin -p password --list-platforms
```

### Download ROM files
```bash
python3 romm_sync.py -s https://your-romm-server.com -u admin -p password --download-roms
```


### Dry run (preview without changes)
```bash
python3 romm_sync.py -s https://your-romm-server.com -u admin -p password --dry-run
```

### Skip image downloads
```bash
python3 romm_sync.py -s https://your-romm-server.com -u admin -p password --no-images
```

### Custom gamelist output directory
```bash
python3 romm_sync.py -s https://your-romm-server.com -u admin -p password -o ~/.emulationstation/gamelists
```

### Use absolute ROM paths (shared filesystem)
```bash
python3 romm_sync.py -s https://your-romm-server.com -u admin -p password --rom-path /romm/library/roms
```

### Download ROM files
```bash
python3 romm_sync.py -s https://your-romm-server.com -u admin -p password --download-roms
```
This will download the actual ROM files from RomM to `~/RetroPie/roms/{platform}/`. By default, only favorites are downloaded.

### Sync ALL ROMs (not just favorites)
```bash
python3 romm_sync.py -s https://your-romm-server.com -u admin -p password --all-roms
```
**Warning:** This will sync your entire ROM library, which may be thousands of ROMs.

### Download all ROM files (favorites + entire library)
```bash
python3 romm_sync.py -s https://your-romm-server.com -u admin -p password --download-roms --all-roms
```
**Warning:** This will download your entire ROM collection, which may be hundreds of GB.

## Directory Structure

### RetroPie (default)
- **ROMs**: `~/RetroPie/roms/{platform}/` - Your actual game files
- **Gamelists**: `./.emulationstation/gamelists/{platform}/gamelist.xml` - Metadata files
- **Images**: `~/.emulationstation/downloaded_images/{platform}/` - Cover art

### SteamDeck (ES-DE)
- **ROMs**: `~/Emulation/roms/{platform}/` - Your actual game files
- **Gamelists**: `~/.emulationstation/gamelists/{platform}/gamelist.xml` - Metadata files
- **Images**: `~/.emulationstation/downloaded_media/{platform}/covers/` - Cover art

### EmuDeck (External Storage)
- **ROMs**: `/run/media/deck/SDCARD/Emulation/roms/{platform}/` - Your actual game files (on SD card)
- **Gamelists**: `~/.emulationstation/gamelists/{platform}/gamelist.xml` - Metadata files
- **Images**: `~/.emulationstation/downloaded_media/{platform}/covers/` - Cover art

## ROM Path Configuration

The script supports two approaches for ROM file paths in `gamelist.xml`:

### Approach 1: Relative Paths (Default)
Use when ROMs are in RetroPie's standard location (`~/RetroPie/roms/{platform}/`):
```xml
<path>./Super Mario World (USA).sfc</path>
```
EmulationStation resolves this relative to: `~/RetroPie/roms/snes/`

### Approach 2: Absolute Paths (Shared Filesystem)
Use when RetroPie accesses RomM's ROM directory directly (network mount, shared storage, etc.):
```bash
python3 romm_sync.py ... --rom-path /romm/library/roms
```
Generates:
```xml
<path>/romm/library/roms/snes/Super Mario World (USA).sfc</path>
```

**Recommended:** Use absolute paths with `--rom-path` if RomM and RetroPie share the same filesystem to avoid duplicating ROMs.

## Output Structure

```
~/.emulationstation/
├── gamelists/
│   ├── snes/
│   │   └── gamelist.xml
│   ├── nes/
│   │   └── gamelist.xml
│   └── gba/
│       └── gamelist.xml
└── downloaded_images/
    ├── snes/
    │   ├── 123-image.png
    │   └── 456-image.png
    ├── nes/
    │   ├── 789-image.png
    │   └── 101-image.png
    └── gba/
        └── 202-image.png

~/RetroPie/roms/
├── snes/
│   └── [ROM files]
├── nes/
│   └── [ROM files]
└── gba/
    └── [ROM files]
```

## Target Systems

Use the `--target` flag to specify your system:

- `--target retropie` (default) - RetroPie on Raspberry Pi
- `--target steamdeck` - EmulationStation Desktop Edition on SteamDeck (internal storage)
- `--target emudeck` - EmuDeck on SteamDeck with external storage (requires `--rom-path`)

You can override individual paths with:
- `-o` / `--output` - Custom gamelist output directory
- `--rom-path` - Custom ROM base path for gamelist.xml (required for emudeck target)

## Platform Mapping

The script maps RomM platform slugs to EmulationStation folder names. Examples:
- `snes` → `snes`
- `genesis` → `megadrive`
- `game-boy-advance` → `gba`
- `psx` → `psx`

See `PLATFORM_MAP` in the script for the complete list (40+ platforms).

## Metadata Fields

Synced from RomM to EmulationStation:
- **name** - Game title
- **desc** - Game description/summary
- **image** - Cover art (downloaded to `~/.emulationstation/downloaded_images/{platform}/`)
- **rating** - IGDB rating (0-1 scale)
- **releasedate** - First release date
- **developer** - Developer name(s)
- **publisher** - Publisher name(s)
- **genre** - Game genre(s)
- **players** - Number of players (integer: 1, 4, etc.)
- **kidgame** - Set to "true" for ROMs in the "Kid Friendly" collection

## Automatic Cleanup

When syncing favorites, the script automatically removes games that are no longer favorited:

1. **Parses existing gamelist.xml** to track previously synced games
2. **Compares with current favorites** from RomM
3. **Removes unfavorited games**:
   - Deletes ROM files from `~/RetroPie/roms/{platform}/` (or target-specific path)
   - Deletes cover images from images directory
   - Removes entries from gamelist.xml

This ensures your picade/device only contains games you currently have favorited in RomM.

**Example:**
```bash
# First sync - downloads 10 favorite games
python3 romm_sync.py -s https://your-romm-server.com -u admin -p password

# Remove favorite status from 3 games in RomM

# Second sync - automatically removes those 3 games
python3 romm_sync.py -s https://your-romm-server.com -u admin -p password
# Output: "Found 3 game(s) to remove (no longer favorited)"
```

**Note:** Automatic cleanup only happens when syncing favorites (default mode). When using `--all-roms`, no cleanup occurs.

## Notes

- **Default behavior**: Syncs ONLY favorites (use `--all-roms` to sync entire library)
- **Automatic cleanup**: Removes unfavorited games' ROMs and images (favorites mode only)
- **Target systems**: Use `--target retropie`, `--target steamdeck`, or `--target emudeck` to set appropriate paths
- **ROM downloads**: Use `--download-roms` to download ROM files (paths vary by target)
- **Kid-friendly games**: Create a "Kid Friendly" collection in RomM to automatically set `<kidgame>true</kidgame>` flag
- **ROM paths**: Default is relative (`./`). Use `--rom-path` for absolute paths when sharing filesystem with RomM
- **Images**: Downloaded to target-specific paths (RetroPie: `downloaded_images/`, ES-DE: `downloaded_media/{platform}/covers/`)
- **Skip existing files**: Both ROM files and images skip re-downloading if they already exist
- **Image naming**: Uses ROM IDs to ensure uniqueness
- **Idempotent**: Existing images are skipped (no re-download)
- **Rate limiting**: 0.5s delay every 10 downloads
- **Retry logic**: 3 attempts with exponential backoff for failed requests
- **Player counts**: Default to 4 for multiplayer games, 1 for single-player
