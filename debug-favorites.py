#!/usr/bin/env python3
"""
Debug script to troubleshoot favorites collection issues.
"""

import sys
import requests
from requests.auth import HTTPBasicAuth

def main():
    if len(sys.argv) < 4:
        print("Usage: python3 debug-favorites.py <server_url> <username> <password>")
        sys.exit(1)
    
    server = sys.argv[1]
    username = sys.argv[2]
    password = sys.argv[3]
    
    # Create session
    session = requests.Session()
    session.auth = HTTPBasicAuth(username, password)
    
    print(f"Connecting to: {server}")
    print(f"Username: {username}")
    print("=" * 60)
    
    # Get collections
    print("\n1. Fetching collections...")
    try:
        response = session.get(f"{server}/api/collections")
        response.raise_for_status()
        collections = response.json()
        
        print(f"Found {len(collections)} collections:")
        for col in collections:
            print(f"  - ID: {col.get('id')}, Name: '{col.get('name')}', ROMs: {col.get('roms_count', 'N/A')}")
        
        # Find favorites
        favorites_id = None
        for col in collections:
            if 'favour' in col.get('name', '').lower():
                favorites_id = col.get('id')
                print(f"\n✓ Found Favourites collection: ID={favorites_id}, Name='{col.get('name')}'")
                print(f"  ROMs in collection: {col.get('roms_count', 'Unknown')}")
                break
        
        if not favorites_id:
            print("\n✗ No Favourites collection found!")
            print("  Looking for collections with 'favour' in the name")
            return
            
    except Exception as e:
        print(f"Error fetching collections: {e}")
        return
    
    # Get platforms
    print("\n2. Fetching platforms...")
    try:
        response = session.get(f"{server}/api/platforms")
        response.raise_for_status()
        platforms = response.json()
        print(f"Found {len(platforms)} platforms")
    except Exception as e:
        print(f"Error fetching platforms: {e}")
        return
    
    # Test getting ROMs with favorites filter
    print("\n3. Testing ROM fetch with favorites filter...")
    if platforms:
        test_platform = platforms[0]
        platform_id = test_platform.get('id')
        platform_name = test_platform.get('name')
        
        print(f"Testing with platform: {platform_name} (ID: {platform_id})")
        
        # Test 1: Get all ROMs for platform
        try:
            response = session.get(f"{server}/api/roms", params={
                "platform_id": platform_id,
                "limit": 1000
            })
            response.raise_for_status()
            all_roms_data = response.json()
            
            if isinstance(all_roms_data, dict) and "items" in all_roms_data:
                all_roms = all_roms_data["items"]
                total_count = all_roms_data.get("total", len(all_roms))
            else:
                all_roms = all_roms_data
                total_count = len(all_roms)
            
            print(f"  All ROMs: {len(all_roms)} returned, {total_count} total")
        except Exception as e:
            print(f"  Error fetching all ROMs: {e}")
            all_roms = []
        
        # Test 2: Get favorites only for platform
        try:
            response = session.get(f"{server}/api/roms", params={
                "platform_id": platform_id,
                "collection_id": favorites_id,
                "limit": 1000
            })
            response.raise_for_status()
            fav_roms_data = response.json()
            
            if isinstance(fav_roms_data, dict) and "items" in fav_roms_data:
                fav_roms = fav_roms_data["items"]
                fav_total = fav_roms_data.get("total", len(fav_roms))
            else:
                fav_roms = fav_roms_data
                fav_total = len(fav_roms)
            
            print(f"  Favorites: {len(fav_roms)} returned, {fav_total} total")
        except Exception as e:
            print(f"  Error fetching favorites: {e}")
            fav_roms = []
    
    # Test 3: Get all favorites across all platforms
    print("\n4. Testing all favorites (no platform filter)...")
    try:
        response = session.get(f"{server}/api/roms", params={
            "collection_id": favorites_id,
            "limit": 1000
        })
        response.raise_for_status()
        all_fav_data = response.json()
        
        if isinstance(all_fav_data, dict) and "items" in all_fav_data:
            all_favs = all_fav_data["items"]
            all_fav_total = all_fav_data.get("total", len(all_favs))
        else:
            all_favs = all_fav_data
            all_fav_total = len(all_favs)
        
        print(f"  Total favorites (all platforms): {len(all_favs)} returned, {all_fav_total} total")
        
        if all_fav_total > 1000:
            print(f"\n⚠ WARNING: You have {all_fav_total} total favorites!")
            print("  The API limit is 1000, so not all favorites will be synced.")
            print("  Consider using platform-specific syncs or reducing favorites.")
        
    except Exception as e:
        print(f"  Error fetching all favorites: {e}")
    
    print("\n" + "=" * 60)
    print("Debug complete!")

if __name__ == "__main__":
    main()
