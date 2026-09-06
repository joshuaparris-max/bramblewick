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
var _base_pos: Vector2
var _move_timer: Timer
var _aggro_radius: float = 4.0
var _wander_radius: float = 2.0

func setup(id: String, pos: Array, key: String) -> void:
	monster_id = id
	_pos = pos
	spawn_key = key

func _ready() -> void:
	add_to_group("monster")
	position = Vector2(_pos[0] * TILE + TILE / 2.0, _pos[1] * TILE + TILE / 2.0)
	_base_pos = position
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
	
	_move_timer = Timer.new()
	_move_timer.wait_time = 1.0 + randf() * 1.5
	_move_timer.autostart = true
	_move_timer.timeout.connect(_on_move_timer)
	add_child(_move_timer)
	
	EventBus.combat_started.connect(func(_mid): _move_timer.paused = true)
	EventBus.combat_ended.connect(func(_v, _k): _move_timer.paused = false)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		EventBus.encounter_requested.emit(monster_id, spawn_key)

func _on_move_timer() -> void:
	var player = get_tree().get_first_node_in_group("player")
	var target_pos := position
	
	if player and position.distance_to(player.global_position) <= _aggro_radius * TILE:
		var diff = player.global_position - position
		if abs(diff.x) > abs(diff.y):
			target_pos += Vector2(sign(diff.x), 0) * TILE
		else:
			target_pos += Vector2(0, sign(diff.y)) * TILE
	else:
		var dir = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT][randi() % 4]
		var candidate = position + dir * TILE
		if candidate.distance_to(_base_pos) <= _wander_radius * TILE:
			target_pos = candidate
			
	if target_pos != position:
		_try_move(target_pos)
		
	_move_timer.wait_time = 0.8 + randf() * 1.0

func _try_move(target: Vector2) -> void:
	var space := get_world_2d().direct_space_state
	var q := PhysicsPointQueryParameters2D.new()
	q.position = target
	q.collision_mask = 1 # Environment
	q.collide_with_areas = true
	var res = space.intersect_point(q)
	
	var blocked = false
	for hit in res:
		var c = hit.collider
		if c is StaticBody2D: blocked = true
		elif c.is_in_group("portal"): blocked = true
		elif c.is_in_group("npc"): blocked = true
		elif c.is_in_group("monster") and c != self: blocked = true
		# It can collide with the player to trigger an encounter!
	
	if not blocked:
		var tw := create_tween()
		tw.tween_property(self, "position", target, 0.3)
