import json
maps = ["village_crafts", "village_market", "village_old", "village_outskirts", "village_river", "wilderness"]
for m in maps:
    with open(f"data/maps/{m}.json", "r") as f:
        d = json.load(f)
        print(f"--- {m} ---")
        for i, row in enumerate(d["grid"]):
            print(f"{i:2}: {row}")
