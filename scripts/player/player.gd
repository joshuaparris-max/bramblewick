extends CharacterBody2D
## MODULE: Player Controller
## PURPOSE: Movement, collision and interaction ONLY. It knows nothing about
##   quests, dialogue content, combat rules or inventory - it just moves and
##   asks the nearest Interactable to interact().
## SAFE TO EDIT: speed, acceleration feel, animation hooks in _update_visual.
## DANGEROUS: adding game logic here. If you're typing the word "quest" in this
##   file, stop and use EventBus instead.
## PUBLIC API: (none needed) - reacts to input actions from InputBootstrap.
## FUTURE: sprite + AnimationPlayer (see _update_visual), dash, footstep SFX
##   via AudioManager.play_sfx("step").

const SPEED := 180.0
const TILE := 32

var _token: TokenIcon
var _frozen := false

func _ready() -> void:
	add_to_group("player")
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 12.0
	shape.shape = circle
	add_child(shape)
	var c := Db.get_class_def(GameState.player.get("class_id", ""))
	_token = TokenIcon.create(c.get("icon", "knight"),
		"player_" + str(GameState.player.get("class_id", "")),
		Color("e8b45a"), Color("e8c878"), 13.0)
	add_child(_token)
	var cam := Camera2D.new()
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = 8.0
	cam.zoom = Vector2(1.6, 1.6)
	add_child(cam)
	EventBus.dialogue_started.connect(func(_n): _frozen = true)
	EventBus.dialogue_finished.connect(func(_n): _frozen = false)

func _physics_process(_delta: float) -> void:
	if _frozen:
		velocity = Vector2.ZERO
		return
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = dir * SPEED
	move_and_slide()
	_update_visual(dir)
	GameState.player_pos = Vector2i(roundi(position.x / TILE), roundi(position.y / TILE))

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and not _frozen:
		_try_interact()

func _try_interact() -> void:
	var best: Node = null
	var best_d := 56.0   # interaction reach in pixels
	for node in get_tree().get_nodes_in_group("interactable"):
		var dist: float = global_position.distance_to(node.global_position)
		if dist < best_d:
			best_d = dist
			best = node
	if best != null and best.has_method("interact"):
		best.interact()

func _update_visual(dir: Vector2) -> void:
	# Animation hook: swap this for AnimatedSprite2D.play("walk_"+direction).
	_token.modulate = Color(1.18, 1.18, 1.1) if dir != Vector2.ZERO else Color.WHITE
