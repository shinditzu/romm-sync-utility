#!/usr/bin/env python3
"""
Unit tests for game removal functionality.
"""

import pytest
import tempfile
import xml.etree.ElementTree as ET
from pathlib import Path
from romm_sync import parse_existing_gamelist, remove_unfavorited_games


class TestParseExistingGamelist:
    """Tests for parse_existing_gamelist function."""
    
    def test_parse_valid_gamelist(self):
        """Test parsing a valid gamelist.xml file."""
        with tempfile.NamedTemporaryFile(mode='w', suffix='.xml', delete=False) as f:
            f.write("""<?xml version="1.0"?>
<gameList>
    <game>
        <path>./game1.sfc</path>
        <name>Super Mario World</name>
        <image>~/.emulationstation/downloaded_images/snes/123-image.png</image>
    </game>
    <game>
        <path>./game2.sfc</path>
        <name>The Legend of Zelda</name>
        <image>~/.emulationstation/downloaded_images/snes/456-image.png</image>
    </game>
</gameList>""")
            gamelist_path = Path(f.name)
        
        try:
            result = parse_existing_gamelist(gamelist_path)
            
            assert len(result) == 2
            assert 'Super Mario World' in result
            assert 'The Legend of Zelda' in result
            assert result['Super Mario World']['path'] == './game1.sfc'
            assert result['Super Mario World']['image'] == '~/.emulationstation/downloaded_images/snes/123-image.png'
        finally:
            gamelist_path.unlink()
    
    def test_parse_nonexistent_gamelist(self):
        """Test parsing a non-existent gamelist.xml file."""
        result = parse_existing_gamelist(Path('/nonexistent/path/gamelist.xml'))
        assert result == {}
    
    def test_parse_empty_gamelist(self):
        """Test parsing an empty gamelist.xml file."""
        with tempfile.NamedTemporaryFile(mode='w', suffix='.xml', delete=False) as f:
            f.write("""<?xml version="1.0"?>
<gameList>
</gameList>""")
            gamelist_path = Path(f.name)
        
        try:
            result = parse_existing_gamelist(gamelist_path)
            assert result == {}
        finally:
            gamelist_path.unlink()
    
    def test_parse_gamelist_without_images(self):
        """Test parsing a gamelist.xml with games that have no images."""
        with tempfile.NamedTemporaryFile(mode='w', suffix='.xml', delete=False) as f:
            f.write("""<?xml version="1.0"?>
<gameList>
    <game>
        <path>./game1.sfc</path>
        <name>Game Without Image</name>
    </game>
</gameList>""")
            gamelist_path = Path(f.name)
        
        try:
            result = parse_existing_gamelist(gamelist_path)
            assert len(result) == 1
            assert 'Game Without Image' in result
            assert result['Game Without Image']['path'] == './game1.sfc'
            assert 'image' not in result['Game Without Image']
        finally:
            gamelist_path.unlink()


class TestRemoveUnfavoritedGames:
    """Tests for remove_unfavorited_games function."""
    
    def test_no_games_to_remove(self):
        """Test when all existing games are still in current favorites."""
        current_roms = [
            {'name': 'Game 1', 'id': 1},
            {'name': 'Game 2', 'id': 2},
        ]
        existing_games = {
            'Game 1': {'path': './game1.sfc', 'image': 'image1.png'},
            'Game 2': {'path': './game2.sfc', 'image': 'image2.png'},
        }
        
        with tempfile.TemporaryDirectory() as tmpdir:
            roms_path = Path(tmpdir) / 'roms'
            images_path = Path(tmpdir) / 'images'
            roms_path.mkdir()
            images_path.mkdir()
            
            removed_roms, removed_images = remove_unfavorited_games(
                current_roms, existing_games, roms_path, images_path, dry_run=False
            )
            
            assert removed_roms == 0
            assert removed_images == 0
    
    def test_remove_unfavorited_game(self):
        """Test removing a game that is no longer in favorites."""
        current_roms = [
            {'name': 'Game 1', 'id': 1},
        ]
        existing_games = {
            'Game 1': {'path': './game1.sfc', 'image': 'image1.png'},
            'Game 2': {'path': './game2.sfc', 'image': 'image2.png'},
        }
        
        with tempfile.TemporaryDirectory() as tmpdir:
            roms_path = Path(tmpdir) / 'roms'
            images_path = Path(tmpdir) / 'images'
            roms_path.mkdir()
            images_path.mkdir()
            
            # Create dummy files
            (roms_path / 'game2.sfc').write_text('dummy rom')
            (images_path / 'image2.png').write_text('dummy image')
            
            removed_roms, removed_images = remove_unfavorited_games(
                current_roms, existing_games, roms_path, images_path, dry_run=False
            )
            
            assert removed_roms == 1
            assert removed_images == 1
            assert not (roms_path / 'game2.sfc').exists()
            assert not (images_path / 'image2.png').exists()
    
    def test_dry_run_mode(self):
        """Test dry run mode doesn't actually delete files."""
        current_roms = [
            {'name': 'Game 1', 'id': 1},
        ]
        existing_games = {
            'Game 1': {'path': './game1.sfc', 'image': 'image1.png'},
            'Game 2': {'path': './game2.sfc', 'image': 'image2.png'},
        }
        
        with tempfile.TemporaryDirectory() as tmpdir:
            roms_path = Path(tmpdir) / 'roms'
            images_path = Path(tmpdir) / 'images'
            roms_path.mkdir()
            images_path.mkdir()
            
            # Create dummy files
            (roms_path / 'game2.sfc').write_text('dummy rom')
            (images_path / 'image2.png').write_text('dummy image')
            
            removed_roms, removed_images = remove_unfavorited_games(
                current_roms, existing_games, roms_path, images_path, dry_run=True
            )
            
            assert removed_roms == 0
            assert removed_images == 0
            assert (roms_path / 'game2.sfc').exists()
            assert (images_path / 'image2.png').exists()
    
    def test_remove_with_absolute_paths(self):
        """Test removing games with absolute paths in gamelist."""
        current_roms = [
            {'name': 'Game 1', 'id': 1},
        ]
        existing_games = {
            'Game 1': {'path': './game1.sfc', 'image': 'image1.png'},
            'Game 2': {'path': '/absolute/path/to/game2.sfc', 'image': '/absolute/path/to/image2.png'},
        }
        
        with tempfile.TemporaryDirectory() as tmpdir:
            roms_path = Path(tmpdir) / 'roms'
            images_path = Path(tmpdir) / 'images'
            roms_path.mkdir()
            images_path.mkdir()
            
            # Create dummy files with just the filename
            (roms_path / 'game2.sfc').write_text('dummy rom')
            (images_path / 'image2.png').write_text('dummy image')
            
            removed_roms, removed_images = remove_unfavorited_games(
                current_roms, existing_games, roms_path, images_path, dry_run=False
            )
            
            assert removed_roms == 1
            assert removed_images == 1
            assert not (roms_path / 'game2.sfc').exists()
            assert not (images_path / 'image2.png').exists()
    
    def test_remove_game_without_image(self):
        """Test removing a game that has no image."""
        current_roms = [
            {'name': 'Game 1', 'id': 1},
        ]
        existing_games = {
            'Game 1': {'path': './game1.sfc'},
            'Game 2': {'path': './game2.sfc'},
        }
        
        with tempfile.TemporaryDirectory() as tmpdir:
            roms_path = Path(tmpdir) / 'roms'
            images_path = Path(tmpdir) / 'images'
            roms_path.mkdir()
            images_path.mkdir()
            
            # Create dummy ROM file
            (roms_path / 'game2.sfc').write_text('dummy rom')
            
            removed_roms, removed_images = remove_unfavorited_games(
                current_roms, existing_games, roms_path, images_path, dry_run=False
            )
            
            assert removed_roms == 1
            assert removed_images == 0
            assert not (roms_path / 'game2.sfc').exists()
    
    def test_remove_nonexistent_files(self):
        """Test removing games when files don't exist (edge case)."""
        current_roms = []
        existing_games = {
            'Game 1': {'path': './game1.sfc', 'image': 'image1.png'},
        }
        
        with tempfile.TemporaryDirectory() as tmpdir:
            roms_path = Path(tmpdir) / 'roms'
            images_path = Path(tmpdir) / 'images'
            roms_path.mkdir()
            images_path.mkdir()
            
            removed_roms, removed_images = remove_unfavorited_games(
                current_roms, existing_games, roms_path, images_path, dry_run=False
            )
            
            assert removed_roms == 0
            assert removed_images == 0
