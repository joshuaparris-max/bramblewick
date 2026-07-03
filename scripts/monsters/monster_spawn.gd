extends Area2D
## MODULE: Monsters (overworld spawn)
## PURPOSE: A visible enemy on the map. Touching it requests an encounter via
##   EventBus - combat itself happens in the Combat module. Stat blocks live
##   in data/monsters/monsters.json.
## SAFE TO EDIT: visuals, patrol movement, aggro radius (chase the player).
## DANGEROUS: starting combat any way other than EventBus.encounter_requested.
## PUBLIC API: setup(monster_id, pos, spawn_key)
## FUTURE: wandering AI, respawns, packs (multiple monsters per encounter).

const TILE := 32
var monster_id: String
var spawn_key: String
var _pos: Array

func setup(id: String, pos: Array, key: String) -> void:
	monster_id = id
	_pos = pos
	spawn_key = key

func _ready() -> void:
	position = Vector2(_pos[0] * TILE + TILE / 2.0, _pos[1] * TILE + TILE / 2.0)
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 14.0
	shape.shape = circle
	add_child(shape)
	var m := Db.get_monster(monster_id)
	var is_big: bool = m.get("boss", false) or "alpha" in m.get("traits", [])
	var token := TokenIcon.create(m.get("icon", "flame"), monster_id,
		Color(m.get("color", "c4553d")),
		Color("e8b45a") if is_big else Color("8a6a4a"),
		15.0 if is_big else 12.0)
	add_child(token)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		EventBus.encounter_requested.emit(monster_id, spawn_key)
