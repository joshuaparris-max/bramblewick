import json

def add_chest(map_id, chest_data):
    with open(f"data/maps/{map_id}.json", "r", encoding="utf-8") as f:
        data = json.load(f)
    data.setdefault("chests", []).append(chest_data)
    with open(f"data/maps/{map_id}.json", "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)

add_chest("b_warehouse", {"pos": [8, 2], "item": "kael_package", "count": 1})
add_chest("marsh", {"pos": [5, 5], "item": "marsh_root", "count": 1})
add_chest("marsh", {"pos": [12, 12], "item": "marsh_root", "count": 1})
add_chest("marsh", {"pos": [15, 8], "item": "marsh_root", "count": 1})

def add_monsters(map_id, monsters):
    with open(f"data/maps/{map_id}.json", "r", encoding="utf-8") as f:
        data = json.load(f)
    data.setdefault("monsters", []).extend(monsters)
    with open(f"data/maps/{map_id}.json", "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)

add_monsters("b_mill", [
    {"id": "spider", "pos": [2, 2]},
    {"id": "spider", "pos": [7, 3]},
    {"id": "spider", "pos": [3, 7]}
])

print("Placed quest targets.")
