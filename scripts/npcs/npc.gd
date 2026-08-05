extends Area2D

const TILE := 32
var npc_id: String
var _def: Dictionary
var _base_pos: Vector2
var _wander_radius: int
var _patrol: Array
var _patrol_idx: int = 0
var _ambient: bool = false
var _in_dialogue: bool = false

var _move_timer: Timer

func setup(id: String) -> void:
	npc_id = id
	_def = Db.get_npc(id)
	_ambient = _def.get("ambient", false)
	_wander_radius = _def.get("wander_radius", 0)
	_patrol = _def.get("patrol", [])

func _ready() -> void:
	add_to_group("interactable")
	position = Vector2(_def["pos"][0] * TILE + TILE / 2.0, _def["pos"][1] * TILE + TILE / 2.0)
	_base_pos = position
	
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 14.0
	shape.shape = circle
	add_child(shape)
	
	var token := TokenIcon.create(_def.get("icon", "bust"), npc_id,
		Color(_def.get("color", "7fa05a")), Color("c9c4b4"), 13.0)
	add_child(token)
	
	var name_lbl := Presentation.world_label(_def.get("name", npc_id), 11, Vector2(-30, -34))
	add_child(name_lbl)
	
	EventBus.dialogue_started.connect(func(nid): _in_dialogue = true)
	EventBus.dialogue_finished.connect(func(nid): _in_dialogue = false)
	
	if _ambient and (_wander_radius > 0 or _patrol.size() > 0):
		_move_timer = Timer.new()
		_move_timer.wait_time = 2.0 + randf() * 2.0
		_move_timer.autostart = true
		_move_timer.timeout.connect(_on_move_timer)
		add_child(_move_timer)

func _on_move_timer() -> void:
	if _in_dialogue:
		return
	
	var target_pos := position
	if _patrol.size() > 0:
		_patrol_idx = (_patrol_idx + 1) % _patrol.size()
		var p = _patrol[_patrol_idx]
		target_pos = Vector2(p[0] * TILE + TILE / 2.0, p[1] * TILE + TILE / 2.0)
	else:
		var dir = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT][randi() % 4]
		var candidate = position + dir * TILE
		if candidate.distance_to(_base_pos) <= _wander_radius * TILE:
			target_pos = candidate
			
	if target_pos != position:
		_try_move(target_pos)
		_move_timer.wait_time = 2.0 + randf() * 2.0

func _try_move(target: Vector2) -> void:
	var space := get_world_2d().direct_space_state
	var q := PhysicsPointQueryParameters2D.new()
	q.position = target
	q.collision_mask = 1 # Environment/statics
	q.collide_with_areas = true
	var res = space.intersect_point(q)
	
	var blocked = false
	for hit in res:
		if hit.collider is StaticBody2D: blocked = true
		if hit.collider.is_in_group("portal"): blocked = true
		if hit.collider.is_in_group("npc") and hit.collider != self: blocked = true
	
	if not blocked:
		var tw := create_tween()
		tw.tween_property(self, "position", target, 0.3)

func interact() -> void:
	var d_id = _def.get("dialogue", "")
	if d_id != "":
		EventBus.dialogue_requested.emit(d_id, npc_id)
	else:
		EventBus.toast.emit(str(_def.get("name", "Someone")) + " has nothing to say.")
