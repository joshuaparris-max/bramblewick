import json

def update_dialogue(npc_id, quest_id, consume_item, consume_count=1):
    with open(f"data/dialogue/{npc_id}.json", "r", encoding="utf-8") as f:
        data = json.load(f)
    
    start_key = "start" if "start" in data.get("nodes", {}) else "root"
    for opt in data["nodes"][start_key].get("options", data["nodes"][start_key].get("choices", [])):
        evs = opt.get("events", [])
        for ev in evs:
            if ev.get("type") == "turn_in_quest" and ev.get("quest") == quest_id:
                # Add take_item event
                evs.append({"type": "take_item", "item": consume_item, "count": consume_count})
    
    with open(f"data/dialogue/{npc_id}.json", "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)

update_dialogue("kael", "q_lost_delivery", "kael_package", 1)
update_dialogue("nyssa", "q_marsh_roots", "marsh_root", 3)

print("Updated kael and nyssa to consume items on turn-in.")
