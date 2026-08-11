import json
import glob

maps = {}
for fn in glob.glob("data/maps/*.json"):
    with open(fn, "r", encoding="utf-8") as f:
        data = json.load(f)
        maps[data["id"]] = data

bad_portals = []

for m_id, m_data in maps.items():
    for p in m_data.get("portals", []):
        to_map = p.get("to_map")
        to_pos = p.get("to_pos")
        if to_map in maps:
            dest_map = maps[to_map]
            for dp in dest_map.get("portals", []):
                if dp.get("pos") == to_pos:
                    bad_portals.append({
                        "from": m_id,
                        "to": to_map,
                        "lands_on": to_pos,
                        "from_pos": p.get("pos")
                    })

for bp in bad_portals:
    print(f"Bad portal from {bp['from']} at {bp['from_pos']} -> {bp['to']} at {bp['lands_on']}")

