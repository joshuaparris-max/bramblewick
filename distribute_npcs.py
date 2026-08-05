import json
import glob

# Load all maps
maps = {}
for fn in glob.glob("data/maps/*.json"):
    with open(fn, "r", encoding="utf-8") as f:
        data = json.load(f)
        maps[data["id"]] = data

# Load NPCs
with open("data/npcs/npcs.json", "r", encoding="utf-8") as f:
    npcs = json.load(f)

# Hardcoded pristine positions for key NPCs
# Format: npc_id: [x, y]
manual_positions = {
    # Elders Hall
    "elder": [4, 1], # Behind the table at [4,2]
    "vane": [7, 3],  # Off to the side
    
    # Blacksmith (b_blacksmith)
    # Counter usually at [3,3], [4,3]. Forge at [1,1]?
    "smith": [4, 2], # Behind counter
    "garret": [2, 7], # Sweeping near entrance
    
    # Inn (b_inn)
    # Counter usually at [3,3], [4,3].
    "silas_inn": [3, 2], # Behind counter
    "elara": [7, 5],     # Near tables
    
    # Apothecary (b_apothecary)
    "nyssa": [4, 2], # Behind counter
    
    # General Store (b_general_store)
    "kael": [3, 2], # Behind counter
    
    # Bakery (b_bakery - wait, bakery doesn't exist as a shop, but there's a map)
    # Actually wait, there is b_bakery map? Let's auto-place them if they exist
}

# Auto-place logic
for m_id, m_data in maps.items():
    grid = m_data.get("grid", [])
    if not grid: continue
    
    # Map out solid tiles
    solid = set()
    for y, row in enumerate(grid):
        for x, char in enumerate(row):
            if char == '#':
                solid.add((x, y))
                
    # Portals are solid
    for p in m_data.get("portals", []):
        solid.add((p["pos"][0], p["pos"][1]))
        
    # Solid decorations
    for d in m_data.get("decorations", []):
        if d.get("solid"):
            solid.add((d["pos"][0], d["pos"][1]))
            
    # Chests
    for c in m_data.get("chests", []):
        solid.add((c["pos"][0], c["pos"][1]))
        
    map_npcs = m_data.get("npcs", [])
    
    # Occupied by NPCs (to prevent stacking)
    occupied = set(solid)
    
    for npc_id in map_npcs:
        # Find the NPC in npcs.json
        npc_obj = next((n for n in npcs if n["id"] == npc_id), None)
        if not npc_obj: continue
        
        pos = None
        if npc_id in manual_positions:
            px, py = manual_positions[npc_id]
            if (px, py) not in occupied:
                pos = [px, py]
                
        # Fallback to scanning for an open tile
        if not pos:
            # Try to place away from edges if possible
            placed = False
            for y in range(2, len(grid) - 2):
                for x in range(2, len(grid[0]) - 2):
                    if (x, y) not in occupied:
                        pos = [x, y]
                        placed = True
                        break
                if placed: break
                
            if not pos:
                # Emergency scan everywhere
                for y in range(1, len(grid) - 1):
                    for x in range(1, len(grid[0]) - 1):
                        if (x, y) not in occupied:
                            pos = [x, y]
                            break
                    if pos: break
                    
        if pos:
            npc_obj["pos"] = pos
            occupied.add((pos[0], pos[1]))
            #print(f"Placed {npc_id} at {pos} in {m_id}")
        else:
            print(f"WARNING: Could not place {npc_id} in {m_id}")

with open("data/npcs/npcs.json", "w", encoding="utf-8") as f:
    json.dump(npcs, f, indent=2)

print("NPC positions updated.")
