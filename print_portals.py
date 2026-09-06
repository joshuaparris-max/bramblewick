import json
import glob

for fn in glob.glob("data/maps/*.json"):
    with open(fn, "r", encoding="utf-8") as f:
        data = json.load(f)
        
    for p in data.get("portals", []):
        x, y = p["pos"]
        print(f"{data['id']}: portal at {p['pos']} -> {p['to_map']} at {p['to_pos']}")
