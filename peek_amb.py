import json
with open("data/npcs/npcs.json", "r") as f:
    npcs = json.load(f)
for n in npcs:
    if "amb_" in n["id"]:
        print(f"{n['id']} -> {n['dialogue']}")
