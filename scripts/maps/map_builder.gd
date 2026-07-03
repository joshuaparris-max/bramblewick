extends RefCounted
class_name MapBuilder
## MODULE: Map & Exploration (builder)
## PURPOSE: Turns a map definition from data/maps/*.json into nodes: floor and
##   wall tiles, portals, chests, NPCs, monster spawns. Pure construction -
##   no game rules.
## SAFE TO EDIT: TILE_DEFS colours/solidity, new tile characters, new object
##   types in build() (add a matching scripts/maps/*.gd node).
## DANGEROUS: the "spawn_key" format (map:x,y) - saves use it to remember
##   cleared encounters.
## PUBLIC API: static build(map_data, parent) -> Vector2 (player spawn hint)
## FUTURE: swap ColorRect tiles for a TileMapLayer + real tileset (keep the
##   same map JSON, just render differently) - see VIBE_CODER_MODULE_GUIDE.

const TILE := 32
const TILE_DEFS := {
	"#": {"color": "16301a", "solid": true},    # tree / wall
	".": {"color": "1d2a19", "solid": false},   # grass / floor
	",": {"color": "3a2f1f", "solid": false},   # path
	"~": {"color": "10283d", "solid": true},    # water
	"^": {"color": "2b241c", "solid": true},    # rock
	"=": {"color": "241c14", "solid": false},   # mine floor
	"W": {"color": "26201a", "solid": true},    # mine wall
}

static func build(map_data: Dictionary, parent: Node2D) -> void:
	var grid: Array = map_data.get("grid", [])
	for y in grid.size():
		var row: String = grid[y]
		for x in row.length():
			var ch := row[x]
			var def: Dictionary = TILE_DEFS.get(ch, TILE_DEFS["."])
			var tile := WorldTile.create(ch, Color(def["color"]), Vector2i(x, y))
			parent.add_child(tile)
			if def["solid"]:
				var body := StaticBody2D.new()
				var shape := CollisionShape2D.new()
				var rs := RectangleShape2D.new()
				rs.size = Vector2(TILE, TILE)
				shape.shape = rs
				body.add_child(shape)
				body.position = tile.position + Vector2(TILE / 2.0, TILE / 2.0)
				parent.add_child(body)
	for p in map_data.get("portals", []):
		var portal: Area2D = load("res://scripts/maps/portal.gd").new()
		portal.setup(p)
		parent.add_child(portal)
	for c in map_data.get("chests", []):
		var chest: Area2D = load("res://scripts/maps/chest.gd").new()
		chest.setup(c, map_data["id"])
		parent.add_child(chest)
	for npc_id in map_data.get("npcs", []):
		var npc: Area2D = load("res://scripts/npcs/npc.gd").new()
		npc.setup(npc_id)
		parent.add_child(npc)
	for m in map_data.get("monsters", []):
		var key: String = "%s:%d,%d" % [map_data["id"], m["pos"][0], m["pos"][1]]
		if GameState.is_spawn_cleared(key):
			continue
		var spawn: Area2D = load("res://scripts/monsters/monster_spawn.gd").new()
		spawn.setup(m["id"], m["pos"], key)
		parent.add_child(spawn)
