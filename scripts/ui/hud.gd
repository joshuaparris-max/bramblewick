extends CanvasLayer
## MODULE: UI/HUD
## PURPOSE: Displays state: top status bar, toast messages, inventory panel (I),
##   quest journal (J), save button. READ-ONLY window onto the game - the only
##   mutations it triggers go through public module methods (use_item, equip,
##   save_game).
## SAFE TO EDIT: styling everywhere, panel layouts, add an equipment screen.
## DANGEROUS: computing rules here (AC, damage...) - ask GameState/Rules.
## FUTURE: hp bar with tween, minimap, hotbar, settings menu, controller
##   focus navigation (grab_focus on first button when panels open).

var _status: Label
var _toasts: VBoxContainer
var _interaction_prompt: Label
var _panel: PanelContainer
var _panel_body: VBoxContainer
var _dialogue_open := false

func _ready() -> void:
	layer = 5
	_build_ui()
	EventBus.state_changed.connect(_refresh)
	EventBus.toast.connect(_toast)
	EventBus.dialogue_started.connect(func(_npc_id): _dialogue_open = true)
	EventBus.dialogue_finished.connect(func(_npc_id): _dialogue_open = false)
	_refresh()
	set_process(true)

func _process(_delta: float) -> void:
	if _interaction_prompt == null:
		return
	if _dialogue_open or _panel.visible:
		_interaction_prompt.visible = false
		return
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		_interaction_prompt.visible = false
		return
	var player: Node2D = players[0]
	var nearest: Node = null
	var nearest_distance := 56.0
	for node in get_tree().get_nodes_in_group("interactable"):
		var distance := player.global_position.distance_to(node.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = node
	_interaction_prompt.visible = nearest != null

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("open_inventory"):
		_toggle_panel(_fill_inventory)
	elif event.is_action_pressed("open_journal"):
		_toggle_panel(_fill_journal)
	elif event.is_action_pressed("ui_back") and _panel.visible:
		_panel.visible = false

func _refresh() -> void:
	var p: Dictionary = GameState.player
	if p.is_empty(): return
	var slots_txt: String = ("  Slots %d/%d" % [p["slots"], p["slots_max"]]) if int(p.get("slots_max", 0)) > 0 else ""
	_status.text = "%s  Lv %d  XP %d   HP %d/%d  AC %d%s   %d gp   [E] talk  [I] pack  [J] journal" % [
		p["name"], p["level"], p["xp"], p["hp"], p["hp_max"], p["ac"], slots_txt, Inventory.gold]

func _toast(msg: String) -> void:
	var l := Label.new()
	l.text = msg
	l.add_theme_color_override("font_color", Color("e8b45a"))
	_toasts.add_child(l)
	var tw := create_tween()
	tw.tween_interval(2.4)
	tw.tween_property(l, "modulate:a", 0.0, 0.6)
	tw.tween_callback(l.queue_free)

# ---------- panels ----------
func _toggle_panel(filler: Callable) -> void:
	if _panel.visible and _panel.get_meta("mode", Callable()) == filler:
		_panel.visible = false
		return
	_panel.set_meta("mode", filler)
	_panel.visible = true
	filler.call()

func _clear_panel() -> void:
	for child in _panel_body.get_children():
		child.queue_free()

func _fill_inventory() -> void:
	_clear_panel()
	_title("Pack & Character")
	var p: Dictionary = GameState.player
	_line("Stats: " + "  ".join(p["stats"].keys().map(
		func(k): return "%s %d (%+d)" % [k, p["stats"][k], Rules.ability_mod(p["stats"][k])])))
	_line("Attack %+d   Damage %s   Proficiency +%d" % [
		GameState.attack_bonus(), GameState.damage_string(), Rules.proficiency(p["level"])])
	_panel_body.add_child(HSeparator.new())
	if Inventory.items.is_empty():
		_line("Your pack is empty.")
	for item_id in Inventory.items:
		var it := Db.get_item(item_id)
		var row := HBoxContainer.new()
		var lbl := Label.new()
		var equipped: bool = item_id in Inventory.equipment.values()
		lbl.text = "%s x%d%s" % [it.get("name", item_id), Inventory.count(item_id),
			"   [equipped]" if equipped else ""]
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(lbl)
		if it.get("type") == "consumable":
			var use := Button.new()
			use.text = "Use"
			use.pressed.connect(func():
				Inventory.use_item(item_id)
				_fill_inventory())
			row.add_child(use)
		elif it.get("slot", "") != "" and not equipped:
			var eq := Button.new()
			eq.text = "Equip"
			eq.pressed.connect(func():
				Inventory.equip(item_id)
				_fill_inventory())
			row.add_child(eq)
		_panel_body.add_child(row)
	_panel_body.add_child(HSeparator.new())
	var save := Button.new()
	save.text = "Save Game"
	save.pressed.connect(SaveManager.save_game)
	_panel_body.add_child(save)

func _fill_journal() -> void:
	_clear_panel()
	_title("Quest Journal")
	var any := false
	for quest_id in Db.quests:
		var st := QuestManager.state_of(quest_id)
		if st == "inactive": continue
		any = true
		var q := Db.get_quest(quest_id)
		var head := Label.new()
		head.text = "%s  [%s]" % [q.get("name", quest_id), st]
		head.add_theme_color_override("font_color",
			Color("7fa05a") if st == "done" else Color("e8b45a"))
		_panel_body.add_child(head)
		_line(q.get("desc", ""))
		if st != "done":
			_line(QuestManager.objective_text(quest_id))
	if not any:
		_line("No quests yet. The Elder's hall would be a good start.")

func _title(t: String) -> void:
	var l := Label.new()
	l.text = t
	l.add_theme_font_size_override("font_size", 20)
	l.add_theme_color_override("font_color", Color("e8b45a"))
	_panel_body.add_child(l)

func _line(t: String) -> void:
	var l := Label.new()
	l.text = t
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_panel_body.add_child(l)

func _build_ui() -> void:
	var bar := PanelContainer.new()
	bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	add_child(bar)
	_status = Label.new()
	_status.add_theme_font_size_override("font_size", 14)
	bar.add_child(_status)
	_toasts = VBoxContainer.new()
	_toasts.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_toasts.offset_top = 44.0
	add_child(_toasts)
	_interaction_prompt = Label.new()
	_interaction_prompt.text = "[E]  Interact"
	_interaction_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_interaction_prompt.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_interaction_prompt.offset_top = -72.0
	_interaction_prompt.offset_bottom = -40.0
	_interaction_prompt.add_theme_font_size_override("font_size", 18)
	_interaction_prompt.add_theme_color_override("font_color", Color("e8b45a"))
	_interaction_prompt.visible = false
	add_child(_interaction_prompt)
	_panel = PanelContainer.new()
	_panel.set_anchors_preset(Control.PRESET_CENTER)
	_panel.custom_minimum_size = Vector2(560, 380)
	_panel.visible = false
	add_child(_panel)
	var scroll := ScrollContainer.new()
	_panel.add_child(scroll)
	_panel_body = VBoxContainer.new()
	_panel_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_panel_body)
