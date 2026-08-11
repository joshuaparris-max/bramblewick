import json
with open("data/monsters/monsters.json", "r") as f:
    ms = json.load(f)

for m in ms:
    print(f"{m['id']}: patrol={m.get('patrol', [])}, wander={m.get('wander_radius', 0)}, aggro={m.get('aggro_radius', 0)}")
