import json
with open("data/npcs/npcs.json", "r") as f:
    npcs = json.load(f)
for n in npcs:
    if n["dialogue"] == "" and "amb_" in n["id"]:
        n["dialogue"] = n["id"]
with open("data/npcs/npcs.json", "w", encoding="utf-8") as f:
    json.dump(npcs, f, indent=4)
print("Updated npcs.json")
