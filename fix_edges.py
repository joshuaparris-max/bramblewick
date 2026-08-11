import json
import glob
import os

maps = {}
for fn in glob.glob("data/maps/*.json"):
    with open(fn, "r", encoding="utf-8") as f:
        maps[os.path.basename(fn).replace(".json", "")] = json.load(f)

for map_id, data in maps.items():
    grid = data.get("grid", [])
    if not grid: continue
    
    for p in data.get("portals", []):
        x, y = p["pos"]
        c = grid[y][x]
        
        if c in ['#', '~', '^', 'W']:
            # Find an adjacent non-solid tile to move the portal to
            dx, dy = 0, 0
            if x == 0: dx = 1
            elif x == len(grid[y]) - 1: dx = -1
            elif y == 0: dy = 1
            elif y == len(grid) - 1: dy = -1
            elif y == len(grid) - 2: dy = -1 # some maps have bottom wall at h-2?
            else:
                for ax, ay in [(1,0), (-1,0), (0,1), (0,-1)]:
                    if grid[y+ay][x+ax] not in ['#', '~', '^', 'W']:
                        dx, dy = ax, ay
                        break
                        
            new_pos = [x + dx, y + dy]
            print(f"Moving {map_id} portal {p['pos']} -> {new_pos}")
            p["pos"] = new_pos
            
            # Find incoming portal in the target map
            target_map = maps.get(p["to_map"])
            if target_map:
                for tp in target_map.get("portals", []):
                    if tp["to_map"] == map_id:
                        # If this incoming portal lands on our OLD pos or near it
                        # Wait, we know our NEW pos. We should make sure the incoming portal
                        # lands 1 step FURTHER in the same direction, so they don't overlap.
                        # Wait! If the portal is now at [1, 5] (dx=1), the player should land at [2, 5].
                        tp["to_pos"] = [new_pos[0] + dx, new_pos[1] + dy]
                        print(f"  Adjusted incoming portal in {p['to_map']} to land at {tp['to_pos']}")

# Save maps
for map_id, data in maps.items():
    with open(f"data/maps/{map_id}.json", "w", encoding="utf-8") as f:
        json.dump(data, f, indent=4)
        
