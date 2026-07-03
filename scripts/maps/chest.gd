extends Area2D
## MODULE: Map & Exploration (interactable object: chest)
## PURPOSE: A one-time loot container. Example of an "interactable" - copy this
##   pattern for levers, signs, shrines etc.
## PUBLIC API: setup(def, map_id) - def: {pos, items:{id:count}, gold?}

const TILE := 32
var _def: Dictionary
var _key: String

func setup(def: Dictionary, map_id: String) -> void:
	_def = def
	_key = "chest:%s:%d,%d" % [map_id, def["pos"][0], def["pos"][1]]

func _ready() -> void:
	add_to_group("interactable")
	position = Vector2(_def["pos"][0] * TILE + TILE / 2.0, _def["pos"][1] * TILE + TILE / 2.0)
	var lbl := Presentation.world_label("[]" if not GameState.get_flag(_key) else "[_]", 16, Vector2(-8, -12))
	lbl.modulate = Color("e8b45a")
	add_child(lbl)

func interact() -> void:
	if GameState.get_flag(_key):
		EventBus.toast.emit("Empty.")
		return
	GameState.set_flag(_key)
	for item_id in _def.get("items", {}):
		Inventory.add(item_id, int(_def["items"][item_id]))
		EventBus.toast.emit("Found: " + Db.get_item(item_id).get("name", item_id))
	if _def.has("gold"):
		Inventory.add_gold(int(_def["gold"]))
		EventBus.toast.emit("Found %d gold" % int(_def["gold"]))
	EventBus.chest_opened.emit(_key)
	if get_child_count() > 0 and get_child(0) is Label:
		get_child(0).text = "[_]"
