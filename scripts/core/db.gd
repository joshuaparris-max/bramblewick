extends Node
## MODULE: Db (core / data)
## PURPOSE: Loads ALL game content from res://data/*.json into dictionaries.
##   Content lives in data files, never hardcoded in scripts.
## SAFE TO EDIT: add new data folders + a loader line in _ready();
##   add helper getters.
## DANGEROUS: changing key names ("classes", "items"...) breaks lookups everywhere.
## PUBLIC API: Db.classes, Db.monsters, Db.npcs, Db.items, Db.quests,
##   Db.dialogues, Db.maps  (all Dictionary keyed by id)
##   Db.get_item(id), Db.get_monster(id), Db.get_npc(id), Db.get_map(id),
##   Db.get_dialogue(id), Db.get_class_def(id), Db.get_quest(id)
## FUTURE: mod folder loading, localisation, hot-reload in debug builds.

var classes: Dictionary = {}
var monsters: Dictionary = {}
var npcs: Dictionary = {}
var items: Dictionary = {}
var quests: Dictionary = {}
var dialogues: Dictionary = {}
var maps: Dictionary = {}
var shops: Dictionary = {}

func _ready() -> void:
	classes = _load_keyed("res://data/classes/classes.json")
	monsters = _load_keyed("res://data/monsters/monsters.json")
	npcs = _load_keyed("res://data/npcs/npcs.json")
	items = _load_keyed("res://data/items/items.json")
	quests = _load_keyed("res://data/quests/quests.json")
	dialogues = _load_dir("res://data/dialogue")
	maps = _load_dir("res://data/maps")
	print("[Db] loaded: %d classes, %d monsters, %d npcs, %d items, %d quests, %d dialogues, %d maps"
		% [classes.size(), monsters.size(), npcs.size(), items.size(), quests.size(), dialogues.size(), maps.size()])

func _load_json(path: String) -> Variant:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("[Db] Missing data file: " + path)
		return null
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if parsed == null:
		push_error("[Db] Bad JSON in: " + path)
	return parsed

func _load_keyed(path: String) -> Dictionary:
	# File is a JSON array of objects each with an "id"; returns {id: object}.
	var out: Dictionary = {}
	var arr: Variant = _load_json(path)
	if arr is Array:
		for entry in arr:
			out[entry["id"]] = entry
	return out

func _load_dir(dir_path: String) -> Dictionary:
	# Each .json file in the folder is one entry keyed by its "id" field.
	var out: Dictionary = {}
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return out
	for file in dir.get_files():
		if file.ends_with(".json"):
			var data: Variant = _load_json(dir_path + "/" + file)
			if data is Dictionary and data.has("id"):
				out[data["id"]] = data
	return out

func get_item(id: String) -> Dictionary: return items.get(id, {})
func get_monster(id: String) -> Dictionary: return monsters.get(id, {})
func get_npc(id: String) -> Dictionary: return npcs.get(id, {})
func get_map(id: String) -> Dictionary: return maps.get(id, {})
func get_dialogue(id: String) -> Dictionary: return dialogues.get(id, {})
func get_class_def(id: String) -> Dictionary: return classes.get(id, {})
func get_quest(id: String) -> Dictionary: return quests.get(id, {})

