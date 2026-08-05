import json
import glob

with open('data/npcs/npcs.json', 'r', encoding='utf-8-sig') as f:
    npcs = json.load(f)

ambient_npcs = [
    {"id": "amb_market1", "name": "Shopper", "icon": "bust", "map": "village_market", "pos": [7, 4], "dialogue": "", "ambient": True, "wander_radius": 3},
    {"id": "amb_market2", "name": "Merchant", "icon": "bust_cap", "map": "village_market", "pos": [14, 5], "dialogue": "", "ambient": True, "wander_radius": 2},
    {"id": "amb_market3", "name": "Child", "icon": "bust", "map": "village_market", "pos": [18, 3], "dialogue": "", "ambient": True, "wander_radius": 4},
    {"id": "amb_crafts1", "name": "Laborer", "icon": "bust", "map": "village_crafts", "pos": [8, 5], "dialogue": "", "ambient": True, "wander_radius": 3},
    {"id": "amb_crafts2", "name": "Apprentice", "icon": "bust", "map": "village_crafts", "pos": [12, 4], "dialogue": "", "ambient": True, "wander_radius": 2},
    {"id": "amb_old1", "name": "Pilgrim", "icon": "bust_hood", "map": "village_old", "pos": [7, 7], "dialogue": "", "ambient": True, "wander_radius": 3},
    {"id": "amb_old2", "name": "Beggar", "icon": "bust", "map": "village_old", "pos": [14, 6], "dialogue": "", "ambient": True, "wander_radius": 1},
    {"id": "amb_river1", "name": "Fisher", "icon": "bust_cap", "map": "village_river", "pos": [16, 7], "dialogue": "", "ambient": True, "wander_radius": 2},
    {"id": "amb_river2", "name": "Docker", "icon": "bust", "map": "village_river", "pos": [10, 8], "dialogue": "", "ambient": True, "wander_radius": 4},
    {"id": "amb_civic1", "name": "Patrol", "icon": "knight", "map": "village_civic", "pos": [10, 4], "dialogue": "", "ambient": True, "patrol": [[10, 4], [14, 4], [14, 8], [10, 8]]},
    {"id": "amb_civic2", "name": "Acolyte", "icon": "bust_hood", "map": "village_civic", "pos": [5, 4], "dialogue": "", "ambient": True, "wander_radius": 2},
    {"id": "amb_outskirts1", "name": "Farmer", "icon": "bust_cap", "map": "village_outskirts", "pos": [6, 7], "dialogue": "", "ambient": True, "wander_radius": 3},
    {"id": "amb_outskirts2", "name": "Traveler", "icon": "bust", "map": "village_outskirts", "pos": [15, 6], "dialogue": "", "ambient": True, "wander_radius": 4}
]
npcs.extend(ambient_npcs)

with open('data/npcs/npcs.json', 'w', encoding='utf-8') as f:
    json.dump(npcs, f, indent=2)

map_npcs = {}
for npc in npcs:
    map_id = npc.get("map")
    if map_id:
        if map_id not in map_npcs:
            map_npcs[map_id] = []
        map_npcs[map_id].append(npc["id"])

for map_file in glob.glob("data/maps/*.json"):
    with open(map_file, 'r', encoding='utf-8-sig') as f:
        data = json.load(f)
    map_id = data["id"]
    data["npcs"] = map_npcs.get(map_id, [])
    with open(map_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2)
