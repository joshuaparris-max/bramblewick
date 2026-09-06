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
		
# Validate interior reachability and NPC stacking
		var occupied = {}
		for y in range(h):
			for x in range(grid[y].length()):
				var c = grid[y][x]
				if c in ["#", "~", "^", "W"]:
					occupied[Vector2(x, y)] = "wall"
					
		for p in map_data.get("portals", []):
			var pos = Vector2(p["pos"][0], p["pos"][1])
			occupied[pos] = "portal"
			
		for d in map_data.get("decorations", []):
			if d.get("solid", false):
				var pos = Vector2(d["pos"][0], d["pos"][1])
				occupied[pos] = "decoration"
				
		for c in map_data.get("chests", []):
			var pos = Vector2(c["pos"][0], c["pos"][1])
			occupied[pos] = "chest"
			
		for npc_id in map_data.get("npcs", []):
			if not Db.get_npc(npc_id): continue
			var n = Db.get_npc(npc_id)
			var pos = Vector2(n["pos"][0], n["pos"][1])
			if occupied.has(pos):
				push_error("NPC %s in %s overlaps with %s at %s" % [npc_id, map_id, occupied[pos], pos])
				has_error = true
			occupied[pos] = "npc_" + npc_id

		# Reachability (only really matters for interiors right now, but applies to all)
		var portal_adj = []
		for p in map_data.get("portals", []):
			var px = p["pos"][0]
			var py = p["pos"][1]
			for dir in [Vector2(1,0), Vector2(-1,0), Vector2(0,1), Vector2(0,-1)]:
				var adj = Vector2(px, py) + dir
				if adj.x >= 0 and adj.x < w and adj.y >= 0 and adj.y < h:
					if not occupied.has(adj):
						portal_adj.append(adj)
		
		if portal_adj.size() > 0:
			var reach_visited = {}
			var reach_q = [portal_adj[0]]
			reach_visited[portal_adj[0]] = true
			
			while reach_q.size() > 0:
				var curr = reach_q.pop_front()
				for dir in [Vector2(1,0), Vector2(-1,0), Vector2(0,1), Vector2(0,-1)]:
					var adj = curr + dir
					if adj.x >= 0 and adj.x < w and adj.y >= 0 and adj.y < h:
						if not occupied.has(adj) and not reach_visited.has(adj):
							reach_visited[adj] = true
							reach_q.append(adj)
			
			# Check if all NPCs are reachable
			for npc_id in map_data.get("npcs", []):
				if not Db.get_npc(npc_id): continue
				var n = Db.get_npc(npc_id)
				var npos = Vector2(n["pos"][0], n["pos"][1])
				var is_reachable = false
				for dir in [Vector2(1,0), Vector2(-1,0), Vector2(0,1), Vector2(0,-1)]:
					var adj = npos + dir
					if reach_visited.has(adj):
						is_reachable = true
						break
				if not is_reachable:
					push_error("NPC %s in %s is unreachable from entrance" % [npc_id, map_id])
					has_error = true

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
			
			# Ensure NPC is not duplicated in multiple maps
			for other_map_id in Db.maps:
				if other_map_id != map_id and npc_id in Db.maps[other_map_id].get("npcs", []):
					push_error("NPC %s is duplicated in maps %s and %s" % [npc_id, map_id, other_map_id])
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
					
	# Validate required NPCs are in their intended maps
	var required_npcs = {
		"elder": "b_elders_hall",
		"vane": "b_elders_hall",
		"smith": "b_blacksmith",
		"garret": "b_blacksmith",
		"nyssa": "b_apothecary",
		"yanni": "b_carpenter",
		"olen": "b_old_house",
		"vorn": "b_abandoned_house",
		"hobb": "b_mill",
		"kade": "b_guardhouse",
		"tor": "b_stable",
		"kael": "b_general_store",
		"liora": "b_bakery",
		"silas_inn": "b_inn",
		"elara": "b_inn"
	}
	
	for req_npc_id in required_npcs:
		var expected_map = required_npcs[req_npc_id]
		var npc_def = Db.get_npc(req_npc_id)
		
		# Expected map contains that NPC ID
		if not req_npc_id in Db.maps.get(expected_map, {}).get("npcs", []):
			push_error("Required NPC %s is missing from expected map %s" % [req_npc_id, expected_map])
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




