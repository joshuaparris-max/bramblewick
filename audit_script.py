import json, os, glob

def read_json(p):
    with open(p, 'r', encoding='utf-8-sig') as f:
        return json.load(f)

classes = read_json('data/classes/classes.json')
items = read_json('data/items/items.json')
monsters = read_json('data/monsters/monsters.json')
quests = read_json('data/quests/quests.json')
shops = read_json('data/shops/shops.json')

raw_npcs = read_json('data/npcs/npcs.json')
npcs = {}
if isinstance(raw_npcs, list):
    for n in raw_npcs:
        npcs[n['id']] = n
else:
    npcs = raw_npcs

maps = {}
for f in glob.glob('data/maps/*.json'):
    m = read_json(f)
    maps[m['id']] = m

dialogues = {}
for f in glob.glob('data/dialogue/*.json'):
    d = read_json(f)
    dialogues[d['id']] = d

print(f"Classes: {len(classes)}")
print(f"Items: {len(items)}")
print(f"Monsters: {len(monsters)}")
print(f"Quests: {len(quests)}")
print(f"Shops: {len(shops)}")
print(f"NPCs: {len(npcs)}")
print(f"Maps: {len(maps)}")
print(f"Dialogues: {len(dialogues)}")

print("\n--- Map Totals ---")
districts = 0
interiors = 0
wilderness = 0
for k, v in maps.items():
    cat = v.get("category", "")
    if cat == "district": districts += 1
    elif cat == "interior": interiors += 1
    elif cat == "wilderness": wilderness += 1
    else: 
        if k.startswith('b_'): interiors += 1
        elif k.startswith('village_'): districts += 1
        else: wilderness += 1

print(f"Districts: {districts}")
print(f"Interiors: {interiors}")
print(f"Wilderness/Dungeon: {wilderness}")

print("\n--- District vs Interior Mismatches ---")
for npc_id, npc_data in npcs.items():
    declared_map = npc_data.get("map")
    
    actual_maps = []
    for m_id, m_data in maps.items():
        if npc_id in m_data.get("npcs", []):
            actual_maps.append(m_id)
            
    if actual_maps and declared_map not in actual_maps:
        print(f"Mismatch: {npc_id} declares map '{declared_map}' but is actually in {actual_maps}")

# Check dialogues for invalid conditions
print("\n--- Invalid Dialogue Conditions ---")
valid_conds = {"flag", "not_flag", "has_item", "gold_at_least", "quest_state"}
for d_id, d_data in dialogues.items():
    for node_id, node_data in d_data.get("nodes", {}).items():
        for ch in node_data.get("choices", []):
            for req in ch.get("requires", []):
                keys = set(req.keys())
                for k in keys:
                    if k not in valid_conds:
                        print(f"Invalid condition '{k}' in dialogue '{d_id}', node '{node_id}'")

# Write detailed reports for the final markdown
with open('audit_temp.txt', 'w', encoding='utf-8') as f:
    f.write("CLASSES\n")
    if isinstance(classes, dict):
        for k, v in classes.items():
            f.write(f"- {k}: stats={v.get('stats')}, start_eq={v.get('start_eq')}, start_items={v.get('start_items')}, ability={v.get('abilities')}, slots={v.get('slots')}\n")
    elif isinstance(classes, list):
        for v in classes:
             f.write(f"- {v.get('id')}: stats={v.get('stats')}, start_eq={v.get('start_eq')}, start_items={v.get('start_items')}, ability={v.get('abilities')}, slots={v.get('slots')}\n")
             
    f.write("\nITEMS\n")
    if isinstance(items, dict):
        for k, v in items.items():
            f.write(f"- {k}: {v.get('type')}\n")
    elif isinstance(items, list):
        for v in items:
            f.write(f"- {v.get('id')}: {v.get('type')}\n")
            
    f.write("\nMONSTERS\n")
    if isinstance(monsters, dict):
        for k, v in monsters.items():
            f.write(f"- {k}: HP={v.get('hp')} AC={v.get('ac')} DMG={v.get('damage')} TRAITS={v.get('traits')} LOOT={v.get('loot')}\n")
    elif isinstance(monsters, list):
        for v in monsters:
            f.write(f"- {v.get('id')}: HP={v.get('hp')} AC={v.get('ac')} DMG={v.get('damage')} TRAITS={v.get('traits')} LOOT={v.get('loot')}\n")
            
    f.write("\nNPCS\n")
    for k, v in npcs.items():
        f.write(f"- {k}: MAP={v.get('map')} POS={v.get('pos')} DIA={v.get('dialogue')} SHOP={v.get('shop')} WANDER={v.get('wander')}\n")
        
    f.write("\nQUESTS\n")
    if isinstance(quests, dict):
        for k, v in quests.items():
            f.write(f"- {k}: OBJ={v.get('objective')} REQ={v.get('requires')}\n")
    elif isinstance(quests, list):
        for v in quests:
            f.write(f"- {v.get('id')}: OBJ={v.get('objective')} REQ={v.get('requires')}\n")
            
    f.write("\nSHOPS\n")
    if isinstance(shops, dict):
        for k, v in shops.items():
            f.write(f"- {k}: STOCK={v.get('stock')}\n")
    elif isinstance(shops, list):
        for v in shops:
            f.write(f"- {v.get('id')}: STOCK={v.get('stock')}\n")
            
    f.write("\nMAPS\n")
    for k, v in maps.items():
        f.write(f"- {k}: CAT={v.get('category')} PORTALS={len(v.get('portals', []))}\n")

print("Wrote detailed list to audit_temp.txt")
