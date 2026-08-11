import json
import glob
import os

with open("data/npcs/npcs.json", "r", encoding="utf-8") as f:
    npcs = json.load(f)

dialogue_files = [os.path.basename(f).replace(".json", "") for f in glob.glob("data/dialogue/*.json")]

missing = []
for npc in npcs:
    if npc["id"] not in dialogue_files:
        missing.append(npc["id"])

print(f"Total NPCs: {len(npcs)}")
print(f"Total Dialogues: {len(dialogue_files)}")
print(f"NPCs missing dialogue ({len(missing)}):")
for m in missing:
    print(" - " + m)
