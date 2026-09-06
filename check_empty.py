import json
with open("data/npcs/npcs.json", "r") as f:
    npcs = json.load(f)
for n in npcs:
    if n["dialogue"] == "":
        print(f"Still missing dialogue: {n['id']}")
