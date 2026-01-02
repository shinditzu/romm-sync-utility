# Task List

## Completed ✓
- [x] Core RomM API client with authentication (2025-12-22)
- [x] Platform mapping (40+ platforms) (2025-12-22)
- [x] XML generation for EmulationStation (2025-12-22)
- [x] Image download with retry logic (2025-12-22)
- [x] CLI argument parsing (2025-12-22)
- [x] Dry-run mode (2025-12-22)
- [x] Platform filtering (2025-12-22)
- [x] Rate limiting for downloads (2025-12-22)
- [x] Documentation (README, PLANNING, TASK) (2025-12-22)
- [x] EmulationStation spec compliance - image paths and player counts (2025-12-22)
- [x] Flexible ROM path configuration (relative vs absolute paths) (2025-12-22)
- [x] Favorites filtering - sync only ROMs marked as favorites (2025-12-23)
- [x] ROM download support - Download actual ROM files from RomM server (2025-12-23)
- [x] Kid-friendly game flag - Mark games from "Kid Friendly" collection (2025-12-23)
- [x] RetroPie menu integration - Dialog-based menu system for easy access (2025-12-23)
- [x] Configuration file support - External .romm-config for credentials (2025-12-23)
- [x] Multi-target support - RetroPie, SteamDeck (ES-DE), and EmuDeck with --target flag (2025-12-23)
- [x] Automatic removal of unfavorited games - Removes ROMs and images when favorites are removed (2025-12-26)
- [x] Shell installer script - Universal install.sh for easy setup on all platforms (2025-12-28)
- [x] SteamDeck venv-based installation with automatic Steam integration (2025-12-28)
- [x] RetroPie Ports menu auto-creation during installation (2025-12-28)
- [x] Fixed favorites collection detection - Proper error handling when no collection exists (2025-12-28)
- [x] SteamDeck read-only filesystem handling - Uses venv to avoid system modifications (2025-12-28)
- [x] Download progress display - Shows real-time progress for ROM and image downloads (2025-12-31)
- [x] ES-DE path auto-detection - Reads MediaDirectory and ROMDirectory from ES-DE settings (2026-01-01)
- [x] ES-DE image naming - Images named to match ROM filenames for ES-DE compatibility (2026-01-01)
- [x] Removed hardcoded path defaults - Only uses paths from ES-DE configuration (2026-01-01)
- [x] Fixed ROM path generation - Correctly includes /roms/ in gamelist paths (2026-01-01)
- [x] Removed emudeck target - Simplified to retropie and steamdeck only (2026-01-01)
- [x] Logging to file - Logs written to romm-sync directory with timestamps (2026-01-02)
- [x] Removed all-roms option from SteamDeck menu - Only favorites sync available in UI (2026-01-02)
- [x] Refactored installer to copy steam-launcher.sh instead of generating inline (2026-01-02)
- [x] Detailed file operation logging - Logs all directory creation, file downloads, and deletions (2026-01-02)
- [x] Fixed double /roms/ path issue - Correctly handles ES-DE auto-detected paths (2026-01-02)
- [x] Improved SteamDeck sync display - Shows detailed scrollable output instead of pulsing bar (2026-01-02)
- [x] Updated RetroPie documentation - Now recommends using installer like SteamDeck (2026-01-02)
- [x] Improved installer pip handling - Multiple fallback methods including apt-get (2026-01-02)

## In Progress 🔄
- None

## Pending 📋
- None currently identified

## Future Enhancements 💡
- Add screenshot support (RomM provides screenshots API)
- Support for video previews
- Additional target systems (Batocera, Recalbox, etc.)
- Incremental sync (only update changed ROMs)
- Progress bar for large syncs
- Parallel downloads (threading/async)
- Backup existing gamelist.xml before overwrite
- Support for custom platform mappings via config file
- Unit tests
