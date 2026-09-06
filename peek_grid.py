import json

with open("data/maps/village_market.json", "r") as f:
    d = json.load(f)
    print("\n".join(d["grid"][:4]))
