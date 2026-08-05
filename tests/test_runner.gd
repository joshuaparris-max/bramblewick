extends Node

func _ready() -> void:
	print("Running headless test...")
	
	# Wait for autoloads to fully initialize
	await get_tree().process_frame
	await get_tree().process_frame
	
	var passed = true
	passed = passed and test_main_scene()
	passed = passed and test_data_integrity()
	
	if passed:
		print("All tests passed.")
		get_tree().quit(0)
	else:
		print("TESTS FAILED.")
		get_tree().quit(1)

func test_main_scene() -> bool:
	print("Testing main scene...")
	var main_scene = load("res://scenes/main/main.tscn")
	if main_scene == null:
		push_error("Failed to load main scene")
		return false
	var inst = main_scene.instantiate()
	add_child(inst)
	inst.queue_free()
	print("Main scene instantiated and freed cleanly.")
	return true

func test_data_integrity() -> bool:
	print("Testing data integrity...")
	var ok = true
	var Db = get_node("/root/Db")
	
	# Check maps and portals
	for map_id in Db.maps:
		var map_data = Db.maps[map_id]
		var grid = map_data.get("grid", [])
		for portal in map_data.get("portals", []):
			if not Db.maps.has(portal["to_map"]):
				push_error("Map %s portal points to missing map: %s" % [map_id, portal["to_map"]])
				ok = false
			else:
				var dest_map = Db.maps[portal["to_map"]]
				var to_pos = portal["to_pos"]
				var dest_grid = dest_map.get("grid", [])
				if to_pos[1] < 0 or to_pos[1] >= dest_grid.size() or to_pos[0] < 0 or to_pos[0] >= dest_grid[int(to_pos[1])].length():
					push_error("Map %s portal points out of bounds on map %s" % [map_id, portal["to_map"]])
					ok = false
				else:
					var tile = dest_grid[int(to_pos[1])][int(to_pos[0])]
					if tile == "#" or tile == "~":
						push_error("Map %s portal points to solid tile '%s' on map %s at %s" % [map_id, tile, portal["to_map"], to_pos])
						ok = false
		for npc_id in map_data.get("npcs", []):
			if not Db.npcs.has(npc_id):
				push_error("Map %s references missing NPC: %s" % [map_id, npc_id])
				ok = false
		for m in map_data.get("monsters", []):
			if not Db.monsters.has(m["id"]):
				push_error("Map %s references missing monster: %s" % [map_id, m["id"]])
				ok = false
				
	# Check NPCs and Dialogue
	for npc_id in Db.npcs:
		var npc = Db.npcs[npc_id]
		var dialogue_id = npc.get("dialogue", "")
		if dialogue_id != "" and not Db.dialogues.has(dialogue_id):
			push_error("NPC %s references missing dialogue: %s" % [npc_id, dialogue_id])
			ok = false
	
	# Check Dialogues for Shop validity
	for d_id in Db.dialogues:
		var d = Db.dialogues[d_id]
		for node_id in d.get("nodes", {}):
			var node = d["nodes"][node_id]
			for opt in node.get("options", []) + node.get("choices", []):
				for ev in opt.get("events", []):
					if ev.get("type") == "buy":
						if not Db.items.has(ev["item"]):
							push_error("Dialogue %s references missing buy item: %s" % [d_id, ev["item"]])
							ok = false
						if ev.get("cost", -1) < 0:
							push_error("Dialogue %s has invalid cost: %s" % [d_id, ev.get("cost")])
							ok = false

	# Check quests
	for quest_id in Db.quests:
		var q = Db.quests[quest_id]
		if not Db.npcs.has(q.get("giver", "")):
			push_error("Quest %s has invalid giver: %s" % [quest_id, q.get("giver")])
			ok = false
		if not Db.npcs.has(q.get("turn_in", "")):
			push_error("Quest %s has invalid turn_in: %s" % [quest_id, q.get("turn_in")])
			ok = false
		for obj in q.get("objectives", []):
			if obj["type"] == "collect":
				if not Db.items.has(obj["item"]):
					push_error("Quest %s objective item missing: %s" % [quest_id, obj["item"]])
					ok = false
		if q.has("rewards"):
			var rew = q["rewards"]
			for item_id in rew.get("items", {}):
				if not Db.items.has(item_id):
					push_error("Quest %s reward item missing: %s" % [quest_id, item_id])
					ok = false
			
	# Test save data serialization
	var GameState = get_node("/root/GameState")
	GameState.new_game("fighter", "Test Hero")
	var exported = GameState.export_state()
	GameState.import_state(exported)
	if GameState.player.get("name") != "Test Hero":
		push_error("Save import failed to restore player name")
		ok = false
			
	if ok:
		print("Data integrity tests passed.")
	return ok

