import json

with open("data/npcs/npcs.json", "r") as f:
    npcs = json.load(f)

missing = []
for n in npcs:
    if "dialogue" not in n:
        missing.append(n["id"])

print(f"{len(missing)} out of {len(npcs)} NPCs are missing the 'dialogue' key.")
if len(missing) > 0:
    print(missing[:10], "...")
