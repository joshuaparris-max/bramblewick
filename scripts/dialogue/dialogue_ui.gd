extends CanvasLayer
## MODULE: Dialogue
## PURPOSE: Runs branching dialogue trees from data/dialogue/*.json: choices,
##   conditions, skill checks (via Rules), and EVENTS. Dialogue changes the
##   world only by firing well-defined events handled in _apply_event() -
##   it never rewrites the player object directly.
## SAFE TO EDIT: add condition types in _condition_met(), add event types in
##   _apply_event(), restyle _build_ui().
## DANGEROUS: renaming node/choice JSON keys ("text","choices","next","check",
##   "events","condition") - every dialogue file uses them.
## DATA FORMAT (data/dialogue/<id>.json):
##   {"id":"elder","start":"start","nodes":{
##     "start":{"text":"...","choices":[
##       {"label":"...","next":"n2"},
##       {"label":"...","check":{"skill":"insight","dc":12},"ok":"a","fail":"b"},
##       {"label":"...","condition":{"quest_state":{"id":"q1","is":"ready"}},
##        "events":[{"type":"turn_in_quest","quest":"q1"}],"next":null}]}}}
##   next:null closes the dialogue. Node "text" may be a list -> one is picked
##   at random (variety).
## FUTURE: portraits, typewriter text, voice hooks, per-NPC relationship values.

var _panel: PanelContainer
var _name_lbl: Label
var _text_lbl: RichTextLabel
var _choices_box: VBoxContainer
var _tree_def: Dictionary
var _npc_id: String

func _ready() -> void:
	layer = 10
	_build_ui()
	visible = false
	EventBus.dialogue_requested.connect(start)

func start(dialogue_id: String, npc_id: String) -> void:
	_tree_def = Db.get_dialogue(dialogue_id)
	if _tree_def.is_empty():
		push_warning("[Dialogue] missing tree: " + dialogue_id)
		return
	_npc_id = npc_id
	visible = true
	EventBus.dialogue_started.emit(npc_id)
	_show_node(_tree_def.get("start", "start"))

func _show_node(key: Variant) -> void:
	if key == null:
		_close()
		return
	var node: Dictionary = _tree_def["nodes"].get(key, {})
	if node.is_empty():
		push_warning("[Dialogue] missing node: " + str(key))
		_close()
		return
	_name_lbl.text = Db.get_npc(_npc_id).get("name", _npc_id)
	var t: Variant = node.get("text", "")
	_text_lbl.text = t[randi() % t.size()] if t is Array else str(t)
	for child in _choices_box.get_children():
		child.queue_free()
	var choices: Array = node.get("choices", [])
	if choices.is_empty():
		choices = [{"label": "(Leave)", "next": null}]
	for c in choices:
		if c.has("condition") and not _condition_met(c["condition"]):
			continue
		var btn := Button.new()
		btn.text = c.get("label", "...")
		if c.has("check"):
			btn.text += "  [%s DC %d]" % [str(c["check"]["skill"]).capitalize(), int(c["check"]["dc"])]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(_on_choice.bind(c))
		_choices_box.add_child(btn)

func _on_choice(c: Dictionary) -> void:
	for ev in c.get("events", []):
		_apply_event(ev)
	if c.has("check"):
		var result: Dictionary = Rules.skill_check(c["check"]["skill"], int(c["check"]["dc"]), GameState.player)
		EventBus.toast.emit(result["text"])
		_show_node(c.get("ok") if result["ok"] else c.get("fail"))
	else:
		_show_node(c.get("next"))

func _condition_met(cond: Dictionary) -> bool:
	if cond.has("flag") and not GameState.get_flag(cond["flag"]): return false
	if cond.has("not_flag") and GameState.get_flag(cond["not_flag"]): return false
	if cond.has("has_item") and Inventory.count(cond["has_item"]) < int(cond.get("count", 1)): return false
	if cond.has("gold_at_least") and Inventory.gold < int(cond["gold_at_least"]): return false
	if cond.has("quest_state"):
		var qs: Dictionary = cond["quest_state"]
		if QuestManager.state_of(qs["id"]) != qs["is"]: return false
	return true

func _apply_event(ev: Dictionary) -> void:
	match ev.get("type", ""):
		"start_quest": QuestManager.start_quest(ev["quest"])
		"turn_in_quest": QuestManager.turn_in(ev["quest"])
		"set_flag": GameState.set_flag(ev["flag"], ev.get("value", true))
		"give_item": Inventory.add(ev["item"], int(ev.get("count", 1)))
		"take_item": Inventory.remove(ev["item"], int(ev.get("count", 1)))
		"give_gold": Inventory.add_gold(int(ev["amount"]))
		"take_gold": Inventory.spend_gold(int(ev["amount"]))
		"buy":   # take_gold + give_item in one safe step (fails silently if broke)
			if Inventory.spend_gold(int(ev["cost"])):
				Inventory.add(ev["item"], int(ev.get("count", 1)))
			else:
				EventBus.toast.emit("Not enough gold.")
		"heal_full": GameState.heal_full()
		"quest_event": EventBus.dialogue_event.emit(ev["event"])
		"reputation": GameState.change_reputation(ev["faction"], int(ev["amount"]))
		_: push_warning("[Dialogue] unknown event type: " + str(ev))

func _close() -> void:
	visible = false
	EventBus.dialogue_finished.emit(_npc_id)

func _build_ui() -> void:
	_panel = PanelContainer.new()
	_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_panel.offset_top = -260.0
	_panel.offset_left = 40.0
	_panel.offset_right = -40.0
	_panel.offset_bottom = -16.0
	# Tall nodes (long text + many choices) must expand up over the map,
	# not down past the bottom of the screen.
	_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	add_child(_panel)
	var v := VBoxContainer.new()
	_panel.add_child(v)
	_name_lbl = Label.new()
	_name_lbl.add_theme_color_override("font_color", Color("e8b45a"))
	_name_lbl.add_theme_font_size_override("font_size", 20)
	v.add_child(_name_lbl)
	_text_lbl = RichTextLabel.new()
	_text_lbl.fit_content = true
	_text_lbl.custom_minimum_size = Vector2(0, 90)
	v.add_child(_text_lbl)
	_choices_box = VBoxContainer.new()
	v.add_child(_choices_box)
