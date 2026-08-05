extends Node

func _init() -> void:
	print("Running headless test...")
	call_deferred("_run_tests")

func _run_tests() -> void:
	
	
	print("Testing main scene...")
	var main: Node = load("res://scenes/main/main.tscn").instantiate()
	assert(main != null, "Main scene failed to load")
	main.free()
	print("Main scene instantiated and freed cleanly.")
	
	print("Testing data integrity...")
	var has_error := false
	
	# Portal graph for reachability
	var portal_graph: Dictionary = {}
	
	for map_id in Db.maps:
		portal_graph[map_id] = []
		var map_data = Db.maps[map_id]
		var grid: Array = map_data.get("grid", [])
		var w = grid[0].length() if grid.size() > 0 else 0
		var h = grid.size()
		
		# Validate portals
		for p in map_data.get("portals", []):
			if not Db.maps.has(p["to_map"]):
				push_error("Map %s references missing portal destination: %s" % [map_id, p["to_map"]])
				has_error = true
				continue
			portal_graph[map_id].append(p["to_map"])
			
			var t_map = Db.maps[p["to_map"]]
			var tx: int = p["to_pos"][0]
			var ty: int = p["to_pos"][1]
			var tg: Array = t_map.get("grid", [])
			if ty < 0 or ty >= tg.size() or tx < 0 or tx >= tg[ty].length():
				push_error("Map %s portal to %s lands out of bounds (%d, %d)" % [map_id, p["to_map"], tx, ty])
				has_error = true
			else:
				var tc: String = tg[ty][tx]
				if tc in ["#", "~", "^", "W"]:
					push_error("Map %s portal to %s lands on solid tile '%s' at (%d, %d)" % [map_id, p["to_map"], tc, tx, ty])
					has_error = true
					
		# Validate NPCs
		for npc_id in map_data.get("npcs", []):
			if not Db.get_npc(npc_id):
				push_error("Map %s references missing NPC: %s" % [map_id, npc_id])
				has_error = true
				continue
			var n = Db.get_npc(npc_id)
			var nx = n["pos"][0]
			var ny = n["pos"][1]
			if ny >= 0 and ny < h and nx >= 0 and nx < w:
				var tc = grid[ny][nx]
				if tc in ["#", "~", "^", "W"]:
					push_error("NPC %s in %s placed on solid tile '%s' at (%d, %d)" % [npc_id, map_id, tc, nx, ny])
					has_error = true
			
		# Validate Monsters
		for m in map_data.get("monsters", []):
			if not Db.get_monster(m["id"]):
				push_error("Map %s references missing monster: %s" % [map_id, m["id"]])
				has_error = true
				
		# Validate chests
		for c in map_data.get("chests", []):
			if c.has("item") and not Db.get_item(c["item"]):
				push_error("Map %s chest contains missing item: %s" % [map_id, c["item"]])
				has_error = true
				
	# Reachability (BFS from Market Square)
	var visited = {"village_market": true}
	var q = ["village_market"]
	while q.size() > 0:
		var curr = q.pop_front()
		for nxt in portal_graph.get(curr, []):
			if not visited.has(nxt):
				visited[nxt] = true
				q.append(nxt)
				
	var required_districts = ["village_crafts", "village_old", "village_river", "village_civic", "village_outskirts", "marsh", "north_road", "darkwood_deep"]
	for d in required_districts:
		if not visited.has(d):
			push_error("District/Area %s is unreachable from Market Square!" % d)
			has_error = true
			
	# Validate shops
	for shop_id in Db.shops:
		var shop = Db.shops[shop_id]
		for s in shop.get("stock", []):
			if s.has("item") and not Db.get_item(s["item"]):
				push_error("Shop %s references missing item: %s" % [shop_id, s["item"]])
				has_error = true
				
	# Validate Dialogues
	for d_id in Db.dialogues:
		var d = Db.dialogues[d_id]
		for node_id in d.get("nodes", {}):
			var node = d["nodes"][node_id]
			for opt in node.get("options", node.get("choices", [])):
				if not opt.has("label") and not opt.has("text"):
					push_error("Dialogue %s node %s has option without label" % [d_id, node_id])
					has_error = true
				if opt.has("text"):
					push_error("Dialogue %s node %s uses obsolete 'text' instead of 'label'" % [d_id, node_id])
					has_error = true
					
	if has_error:
		print("TESTS FAILED.")
		get_tree().quit(1)
	else:
		print("Data integrity tests passed.")
		print("All tests passed.")
		get_tree().quit(0)




