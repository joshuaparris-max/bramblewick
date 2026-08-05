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
	# Wait a frame to let main do its _ready routing
	inst.queue_free()
	print("Main scene instantiated and freed cleanly.")
	return true

func test_data_integrity() -> bool:
	print("Testing data integrity...")
	var ok = true
	var Db = get_node("/root/Db")
	if Db == null:
		push_error("Db autoload missing!")
		return false
		
	# Check maps
	for map_id in Db.maps:
		var map_data = Db.maps[map_id]
		for portal in map_data.get("portals", []):
			if not Db.maps.has(portal["to_map"]):
				push_error("Map %s portal points to missing map: %s" % [map_id, portal["to_map"]])
				ok = false
		for npc_id in map_data.get("npcs", []):
			if not Db.npcs.has(npc_id):
				push_error("Map %s references missing NPC: %s" % [map_id, npc_id])
				ok = false
		for m in map_data.get("monsters", []):
			if not Db.monsters.has(m["id"]):
				push_error("Map %s references missing monster: %s" % [map_id, m["id"]])
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
			
	# Test save data serialization
	var GameState = get_node("/root/GameState")
	if GameState == null:
		push_error("GameState missing")
		return false
	
	GameState.new_game("fighter", "Test Hero")
	var exported = GameState.export_state()
	GameState.import_state(exported)
	if GameState.player.get("name") != "Test Hero":
		push_error("Save import failed to restore player name")
		ok = false
	
	# Check input actions
	var required_actions = ["move_up", "move_down", "move_left", "move_right", "interact", "ui_back"]
	for action in required_actions:
		if not InputMap.has_action(action):
			push_error("Missing input action: " + action)
			ok = false
			
	if ok:
		print("Data integrity tests passed.")
	return ok

