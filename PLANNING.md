# Project Planning

## Architecture

### Core Components
1. **RomMClient** - API client for RomM server with retry logic
2. **Target Configuration** - Multi-target support (RetroPie, SteamDeck ES-DE, custom)
3. **Platform Mapper** - Maps RomM slugs to EmulationStation folder names
4. **XML Generator** - Creates EmulationStation gamelist.xml files
5. **Image Downloader** - Downloads cover art with retry/rate limiting

### Data Flow
```
RomM API → RomMClient → Target Config Selection → Platform Sync → XML Generation + Image Download → Target-Specific Folders
```

## Design Decisions

### Multi-Target Support
- Target configurations stored in `TARGET_CONFIGS` dict
- Each target defines: gamelist_path, images_path, roms_path, image_subdir
- Supports RetroPie and SteamDeck (ES-DE) out of the box
- Extensible for additional targets (Batocera, Recalbox, etc.)

### File Structure
- Single-file script for portability
- No external config files (all CLI args)
- Output structure adapts to target system

### Error Handling
- Retry logic for transient failures (429, 500, 502, 503, 504)
- Skip 404s (missing images) without retry
- Continue on per-ROM failures (don't abort entire platform)

### Performance
- Rate limiting: 0.5s delay every 10 image downloads
- Session reuse for connection pooling
- Timeout: 120s for ROM lists, 180s for large queries, 30s for images

### Image Handling
- Use ROM ID for filenames (ensures uniqueness)
- Prefer external URLs (IGDB) over local server
- Skip existing images (idempotent)
- PNG format for all covers

## Style Guide

- **Language**: Python 3.7+
- **Formatting**: PEP8 compliant
- **Type hints**: Used for function signatures
- **Docstrings**: Google style for all functions/classes
- **Error messages**: User-friendly with context

## Constraints

- Must work on RetroPie (Raspberry Pi) and SteamDeck (Linux)
- Minimal dependencies (only `requests`)
- No database/state files
- Must handle large ROM collections (1000+ per platform)
- Backward compatible with existing RetroPie setups
