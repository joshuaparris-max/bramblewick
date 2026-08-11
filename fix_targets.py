import json

def load_map(m):
    with open(f"data/maps/{m}.json", "r", encoding="utf-8") as f:
        return json.load(f)

def save_map(m, data):
    with open(f"data/maps/{m}.json", "w", encoding="utf-8") as f:
        json.dump(data, f, indent=4)

def fix_target(map_id, to_map, new_to_pos):
    d = load_map(map_id)
    for p in d.get("portals", []):
        if p["to_map"] == to_map:
            p["to_pos"] = new_to_pos
            print(f"Fixed {map_id} -> {to_map} landing at {new_to_pos}")
    save_map(map_id, d)

# village_market to village_old lands on '#' at (10, 9)
fix_target("village_market", "village_old", [8, 9])

# village_outskirts to village_market lands on '#' at (10, 9)
fix_target("village_outskirts", "village_market", [8, 9])

