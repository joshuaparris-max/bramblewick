import json

def load_map(m):
    with open(f"data/maps/{m}.json", "r", encoding="utf-8") as f:
        return json.load(f)

def save_map(m, data):
    with open(f"data/maps/{m}.json", "w", encoding="utf-8") as f:
        json.dump(data, f, indent=4)

def update_portal(map_id, old_pos, new_pos, new_to_pos=None):
    d = load_map(map_id)
    for p in d.get("portals", []):
        if p["pos"] == old_pos:
            p["pos"] = new_pos
            if new_to_pos:
                p["to_pos"] = new_to_pos
    save_map(map_id, d)

# 1. village_crafts [19, 5] -> [18, 5], new_to_pos = [2, 5]
update_portal("village_crafts", [19, 5], [18, 5], [2, 5])
# incoming village_market [0, 5] -> [1, 5], new_to_pos = [17, 5]
update_portal("village_market", [0, 5], [1, 5], [17, 5])

# 3. village_crafts [10, 9] -> [8, 9]
update_portal("village_crafts", [10, 9], [8, 9])

# 4. village_market [10, 0] -> [8, 1], to_pos is village_old [10, 9]
update_portal("village_market", [10, 0], [8, 1], [10, 9])

# 5. village_market [21, 5] -> [20, 5], to_pos is village_river [2, 5]
update_portal("village_market", [21, 5], [20, 5], [2, 5])
# 6. village_river [0, 5] -> [1, 5], to_pos is village_market [19, 5]
update_portal("village_river", [0, 5], [1, 5], [19, 5])

# 7. village_market [10, 11] -> [10, 10], to_pos is village_outskirts [4, 3] (no change)
update_portal("village_market", [10, 11], [10, 10])

# 8. village_outskirts [10, 1] -> [8, 1], to_pos is village_market [10, 9]
update_portal("village_outskirts", [10, 1], [8, 1], [10, 9])

# 9. village_old [10, 11] -> [10, 10], to_pos is village_market [4, 3]
update_portal("village_old", [10, 11], [10, 10])

# 10. village_outskirts [10, 11] -> [10, 10]
update_portal("village_outskirts", [10, 11], [10, 10])

print("Applied precision portal fixes.")
