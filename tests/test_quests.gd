extends Node

func _ready() -> void:
	print("Starting world/content quest integration tests...")
	call_deferred("_run_tests")

func _run_tests() -> void:
	# LOST DELIVERY
	print("Testing q_lost_delivery...")
	var warehouse_map = Db.maps["b_warehouse"]
	var package_source = null
	for c in warehouse_map.get("chests", []):
		if c.get("item") == "kael_package":
			package_source = c
			break
	assert(package_source != null, "b_warehouse must contain kael_package source")
	
	var kael_dia = Db.dialogues["kael"]
	var accepts_quest = false
	var turns_in = false
	var consumes_pkg = false
	for n_id in kael_dia.get("nodes", {}):
		var node = kael_dia["nodes"][n_id]
		for opt in node.get("options", node.get("choices", [])):
			for ev in opt.get("events", []):
				if ev.get("type") == "start_quest" and ev.get("quest") == "q_lost_delivery":
					accepts_quest = true
				if ev.get("type") == "turn_in_quest" and ev.get("quest") == "q_lost_delivery":
					turns_in = true
	assert(accepts_quest, "Kael dialogue must accept q_lost_delivery")
	assert(turns_in, "Kael dialogue must turn in q_lost_delivery")
	
	# APOTHECARY'S INGREDIENTS
	print("Testing q_marsh_roots...")
	var marsh = Db.maps["marsh"]
	var roots_found = 0
	for d in marsh.get("chests", []):
		if d.get("item") == "marsh_root":
			roots_found += 1
	assert(roots_found >= 3, "Marsh must have at least 3 marsh_root collectibles")
	var nyssa = Db.dialogues["nyssa"]
	var n_accepts = false
	var n_turns = false
	for n_id in nyssa.get("nodes", {}):
		for opt in nyssa["nodes"][n_id].get("options", nyssa["nodes"][n_id].get("choices", [])):
			for ev in opt.get("events", []):
				if ev.get("type") == "start_quest" and ev.get("quest") == "q_marsh_roots": n_accepts = true
				if ev.get("type") == "turn_in_quest" and ev.get("quest") == "q_marsh_roots": n_turns = true
	assert(n_accepts, "Nyssa dialogue must accept q_marsh_roots")
	assert(n_turns, "Nyssa dialogue must turn in q_marsh_roots")

	# TROUBLE AT THE MILL
	print("Testing q_mill_trouble...")
	var mill = Db.maps["b_mill"]
	var spiders_found = 0
	for m in mill.get("monsters", []):
		if Db.get_monster(m["id"]).get("traits", []).has("spider") or m["id"] == "spider":
			spiders_found += 1
	assert(spiders_found >= 3, "b_mill must contain at least 3 spiders")
	var hobb = Db.dialogues["hobb"]
	var h_accepts = false
	var h_turns = false
	for n_id in hobb.get("nodes", {}):
		for opt in hobb["nodes"][n_id].get("options", hobb["nodes"][n_id].get("choices", [])):
			for ev in opt.get("events", []):
				if ev.get("type") == "start_quest" and ev.get("quest") == "q_mill_trouble": h_accepts = true
				if ev.get("type") == "turn_in_quest" and ev.get("quest") == "q_mill_trouble": h_turns = true
	assert(h_accepts, "Hobb dialogue must accept q_mill_trouble")
	assert(h_turns, "Hobb dialogue must turn in q_mill_trouble")

	# EMPTY HOUSE
	print("Testing q_empty_house...")
	assert(Db.maps["b_abandoned_house"].get("npcs", []).has("vorn"), "Vorn must be in b_abandoned_house")
	assert(not Db.maps["village_market"].get("npcs", []).has("vorn"), "Vorn must NOT be outside")
	var vorn = Db.dialogues["vorn"]
	var v_event = false
	for n_id in vorn.get("nodes", {}):
		for opt in vorn["nodes"][n_id].get("options", vorn["nodes"][n_id].get("choices", [])):
			for ev in opt.get("events", []):
				if ev.get("type") == "quest_event" and ev.get("event") == "found_vorn": v_event = true
	assert(v_event, "Vorn dialogue must emit found_vorn event")
	var olen = Db.dialogues["olen"]
	var o_turns = false
	for n_id in olen.get("nodes", {}):
		for opt in olen["nodes"][n_id].get("options", olen["nodes"][n_id].get("choices", [])):
			for ev in opt.get("events", []):
				if ev.get("type") == "turn_in_quest" and ev.get("quest") == "q_empty_house": o_turns = true
	assert(o_turns, "Olen dialogue must turn in q_empty_house")

	print("ALL QUEST CONTENT VERIFIED.")
	get_tree().quit(0)
