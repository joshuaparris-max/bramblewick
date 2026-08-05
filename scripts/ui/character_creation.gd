extends Control
## MODULE: Character Creation
## PURPOSE: Name + class selection built from data/classes/classes.json.
##   Confirming calls GameState.new_game() - creation never assembles the
##   player dict itself.
## SAFE TO EDIT: layout/styling; show more class details (abilities, gear).
## FUTURE: point-buy or rolled stats, portraits, backgrounds/origins,
##   appearance options, difficulty select.

var _selected := ""
var _name_edit: LineEdit
var _cards: Dictionary = {}

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var v := VBoxContainer.new()
	v.custom_minimum_size = Vector2(720, 0)
	center.add_child(v)
	var t := Label.new()
	t.text = "Who answers Bramblewick's call?"
	t.add_theme_font_size_override("font_size", 26)
	t.add_theme_color_override("font_color", Color("e8b45a"))
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(t)
	_name_edit = LineEdit.new()
	_name_edit.placeholder_text = "Your name"
	_name_edit.max_length = 16
	_name_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(_name_edit)
	v.add_child(HSeparator.new())
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_child(row)
	for class_id in Db.classes:
		var c: Dictionary = Db.classes[class_id]
		var card := Button.new()
		card.toggle_mode = true
		card.custom_minimum_size = Vector2(225, 170)
		card.text = "%s\n\nHP %d  AC-style: %s\n%s" % [
			c["name"], int(c["base_hp"]), c.get("armour_note", ""), c.get("blurb", "")]
		card.clip_text = false
		card.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		card.pressed.connect(_select.bind(class_id))
		row.add_child(card)
		_cards[class_id] = card
	v.add_child(HSeparator.new())
	var go := Button.new()
	go.text = "Begin"
	go.custom_minimum_size = Vector2(0, 44)
	go.pressed.connect(_begin)
	v.add_child(go)
	_select(Db.classes.keys()[0])

func _select(class_id: String) -> void:
	_selected = class_id
	for id in _cards:
		_cards[id].button_pressed = (id == class_id)

func _begin() -> void:
	var pname := _name_edit.text.strip_edges()
	if pname == "":
		pname = "Wanderer"
	GameState.new_game(_selected, pname)
	SceneRouter.goto("explore")
