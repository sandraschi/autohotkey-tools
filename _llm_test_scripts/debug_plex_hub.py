import os
import requests
import json

url = "http://192.168.0.81:32400/hubs/search?query=burt+reynolds"
headers = {"X-Plex-Token": "8DcZg-jSXgUj7yCN3CVm", "Accept": "application/json"}

try:
    response = requests.get(url, headers=headers)
    data = response.json()
    
    hubs = data.get('MediaContainer', {}).get('Hub', [])
    for hub in hubs:
        if hub.get('type') == 'actor':
            print(f"Actor Hub Found. Keys: {hub.keys()}")
            print(json.dumps(hub, indent=2))
            break
            
except Exception as e:
    print(e)

