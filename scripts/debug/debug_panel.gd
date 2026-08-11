extends CanvasLayer
## MODULE: Debug/Test tools (F1)
## PURPOSE: Dev cheats to test any module without playing through: teleport,
##   give items/gold, heal, start combat, fire quest events, roll dice,
##   inspect state, save/load/reset.
## SAFE TO EDIT: add buttons for anything you're building - this panel is the
##   fastest way to test that nothing broke (see VIBE_CODER_MODULE_GUIDE.md).
## FUTURE: console with commands, on-screen state watch, godmode toggle.

var _panel: PanelContainer
var _out: Label

func _ready() -> void:
	layer = 20
	_panel = PanelContainer.new()
	_panel.set_anchors_preset(Control.PRESET_CENTER_LEFT)
	_panel.offset_left = 8.0
	_panel.visible = false
	add_child(_panel)
	var v := VBoxContainer.new()
	_panel.add_child(v)
	var t := Label.new()
	t.text = "DEBUG (F1)"
	t.add_theme_color_override("font_color", Color("c4553d"))
	v.add_child(t)
	_mk(v, "Teleport: village", func(): _teleport("village_market", Vector2i(3, 5)))
	_mk(v, "Teleport: wilderness", func(): _teleport("wilderness", Vector2i(2, 2)))
	_mk(v, "Teleport: mine", func(): _teleport("mine", Vector2i(2, 2)))
	_mk(v, "+50 gold", func(): Inventory.add_gold(50))
	_mk(v, "Give potion x3", func(): Inventory.add("potion_healing", 3))
	_mk(v, "Give 3 wolf pelts", func(): Inventory.add("wolf_pelt", 3))
	_mk(v, "Heal full", GameState.heal_full)
	_mk(v, "+100 XP", func(): GameState.add_xp(100))
	_mk(v, "Fight: wolf", func(): EventBus.encounter_requested.emit("wolf", ""))
	_mk(v, "Fight: BOSS spider", func(): EventBus.encounter_requested.emit("spider_matron", ""))
	_mk(v, "Quest event: test", func(): EventBus.dialogue_event.emit("debug_event"))
	_mk(v, "Roll 3d6+2", func(): _print("3d6+2 = %d" % Rules.roll_dice("3d6+2")))
	_mk(v, "Inspect state", func(): _print(JSON.stringify(GameState.export_state()).left(400)))
	_mk(v, "Save", SaveManager.save_game)
	_mk(v, "Delete save", SaveManager.delete_save)
	_out = Label.new()
	_out.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_out.custom_minimum_size = Vector2(240, 0)
	v.add_child(_out)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_toggle"):
		_panel.visible = not _panel.visible

func _teleport(map: String, pos: Vector2i) -> void:
	GameState.current_map = map
	GameState.player_pos = pos
	SceneRouter.goto("explore")

func _mk(parent: Node, text: String, fn: Callable) -> void:
	var b := Button.new()
	b.text = text
	b.pressed.connect(fn)
	parent.add_child(b)

func _print(t: String) -> void:
	_out.text = t
	print("[Debug] ", t)

