import json
import glob
import os

with open("data/npcs/npcs.json", "r", encoding="utf-8") as f:
    npcs = json.load(f)

print(f"Loaded {len(npcs)} NPCs from npcs.json")
npc_ids = [n["id"] for n in npcs]

dialogues = [os.path.basename(f).replace(".json", "") for f in glob.glob("data/dialogue/*.json")]
print(f"Found {len(dialogues)} dialogue files")

missing = [nid for nid in npc_ids if nid not in dialogues]
print(f"Missing dialogues in npcs.json: {missing}")

# Check maps for NPCs that might not be in npcs.json
map_npcs = set()
for fn in glob.glob("data/maps/*.json"):
    with open(fn, "r", encoding="utf-8") as f:
        m = json.load(f)
        for n in m.get("npcs", []):
            map_npcs.add(n)

not_in_db = [n for n in map_npcs if n not in npc_ids]
print(f"NPCs in maps but NOT in npcs.json: {not_in_db}")

missing_map = [n for n in map_npcs if n not in dialogues]
print(f"NPCs in maps missing dialogues: {missing_map}")
