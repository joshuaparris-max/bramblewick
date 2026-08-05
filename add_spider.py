import json

with open("data/monsters/monsters.json", "r", encoding="utf-8") as f:
    monsters = json.load(f)

monsters.append({
    "id": "spider",
    "name": "Mill Spider",
    "glyph": "s",
    "icon": "spider",
    "color": "404040",
    "hp": 5,
    "ac": 11,
    "attack_bonus": 2,
    "damage": "1d4",
    "initiative_bonus": 3,
    "xp": 10,
    "gold": "1",
    "loot": [],
    "traits": ["spider"],
    "behaviour": "aggressive",
    "flavor": "A fat black spider that has made its home in the mill's shadow."
})

with open("data/monsters/monsters.json", "w", encoding="utf-8") as f:
    json.dump(monsters, f, indent=2)

print("Added spider monster.")
