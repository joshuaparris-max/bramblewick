extends Area2D
## MODULE: Map & Exploration (portal/door/trigger)
## PURPOSE: Walk-on area that moves the player to another map (or position).
## SAFE TO EDIT: add "locked" support (require item/flag before travel).
## PUBLIC API: setup(portal_def)  - def: {pos, to_map, to_pos, label?}

const TILE := 32
var _def: Dictionary

func setup(def: Dictionary) -> void:
	_def = def

func _ready() -> void:
	position = Vector2(_def["pos"][0] * TILE + TILE / 2.0, _def["pos"][1] * TILE + TILE / 2.0)
	var shape := CollisionShape2D.new()
	var rs := RectangleShape2D.new()
	rs.size = Vector2(TILE, TILE)
	shape.shape = rs
	add_child(shape)
	var marker := Presentation.world_label("O", 16, Vector2(-6, -12))
	marker.modulate = Color("6f8fc4")
	add_child(marker)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	if _def.has("requires_flag") and not GameState.get_flag(_def["requires_flag"]):
		EventBus.toast.emit(_def.get("locked_text", "It won't open."))
		return
	# The scene change below is deferred - freeze the player's physics NOW or
	# its _physics_process overwrites player_pos with old-map coordinates
	# before the new map loads (spawning you inside whatever tile that is).
	body.set_physics_process(false)
	GameState.current_map = _def["to_map"]
	GameState.player_pos = Vector2i(_def["to_pos"][0], _def["to_pos"][1])
	EventBus.portal_used.emit(_def["to_map"])
	SceneRouter.goto("explore")
