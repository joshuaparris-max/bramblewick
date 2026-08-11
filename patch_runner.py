import re

with open("tests/test_runner.gd", "r", encoding="utf-8") as f:
    content = f.read()

injection = """
		# Validate interior reachability and NPC stacking
		var occupied = {}
		for y in range(h):
			for x in range(w):
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
"""

# Insert right after "for map_id in Db.maps:" block variables
insert_point = "		# Validate portals"
content = content.replace(insert_point, injection.strip() + "\n\n" + insert_point)

with open("tests/test_runner.gd", "w", encoding="utf-8") as f:
    f.write(content)
print("Injected reachability checks.")
