extends Node
## MODULE: Quests
## PURPOSE: Tracks quest states and objective progress. Quest DEFINITIONS live
##   in data/quests/quests.json. Progress arrives via EventBus signals - combat
##   and dialogue never edit quests directly.
## SAFE TO EDIT: add new objective types in _check_objective_progress
##   (e.g. "talk_to", "reach_map"), add reward types in turn_in().
## DANGEROUS: state strings ("inactive/active/ready/done") - dialogue conditions
##   and saves rely on them exactly.
## PUBLIC API:
##   start_quest(id), state_of(id), progress_of(id) -> Dictionary
##   is_ready(id), turn_in(id), fire_quest_event(name)
##   export_state()/import_state(data)
## FUTURE: timed quests, failure states, branching outcomes, quest chains.

var quest_state: Dictionary = {}    # id -> "inactive"|"active"|"ready"|"done"
var progress: Dictionary = {}       # id -> {objective_id: count}

func _ready() -> void:
	EventBus.monster_killed.connect(_on_monster_killed)
	EventBus.item_gained.connect(_on_item_changed)
	EventBus.item_lost.connect(_on_item_changed)
	EventBus.dialogue_event.connect(fire_quest_event)

func reset() -> void:
	quest_state = {}; progress = {}

func state_of(id: String) -> String:
	return quest_state.get(id, "inactive")

func progress_of(id: String) -> Dictionary:
	return progress.get(id, {})

func start_quest(id: String) -> void:
	if state_of(id) != "inactive":
		return
	quest_state[id] = "active"
	progress[id] = {}
	EventBus.quest_started.emit(id)
	EventBus.toast.emit("Quest started: " + Db.get_quest(id).get("name", id))
	_reevaluate(id)   # collect quests may already be satisfied

func is_ready(id: String) -> bool:
	return state_of(id) == "ready"

func turn_in(id: String) -> void:
	if not is_ready(id):
		return
	quest_state[id] = "done"
	var q := Db.get_quest(id)
	var r: Dictionary = q.get("rewards", {})
	# Collect quests hand the items over on turn-in.
	for obj in q.get("objectives", []):
		if obj.get("type") == "collect":
			Inventory.remove(obj["item"], int(obj.get("count", 1)))
	if r.has("gold"): Inventory.add_gold(int(r["gold"]))
	if r.has("xp"): GameState.add_xp(int(r["xp"]))
	for item_id in r.get("items", {}):
		Inventory.add(item_id, int(r["items"][item_id]))
	EventBus.quest_completed.emit(id)
	EventBus.toast.emit("Quest complete: " + q.get("name", id))

func fire_quest_event(event_name: String) -> void:
	for id in quest_state:
		if state_of(id) != "active": continue
		for obj in Db.get_quest(id).get("objectives", []):
			if obj.get("type") == "event" and obj.get("event") == event_name:
				_bump(id, obj)

func _on_monster_killed(monster_id: String) -> void:
	for id in quest_state:
		if state_of(id) != "active": continue
		for obj in Db.get_quest(id).get("objectives", []):
			if obj.get("type") == "kill" and obj.get("monster") == monster_id:
				_bump(id, obj)

func _on_item_changed(_item_id: String, _n: int) -> void:
	for id in quest_state.keys():
		if state_of(id) in ["active", "ready"]:
			_reevaluate(id)

func _bump(id: String, obj: Dictionary) -> void:
	var p: Dictionary = progress.get(id, {})
	var oid: String = obj.get("id", "obj")
	p[oid] = int(p.get(oid, 0)) + 1
	progress[id] = p
	EventBus.quest_updated.emit(id)
	_reevaluate(id)

func _reevaluate(id: String) -> void:
	var q := Db.get_quest(id)
	var all_done := true
	for obj in q.get("objectives", []):
		if not _objective_done(id, obj):
			all_done = false
	var was := state_of(id)
	if all_done and was == "active":
		quest_state[id] = "ready"
		EventBus.quest_ready.emit(id)
		EventBus.toast.emit("Quest ready to turn in: " + q.get("name", id))
	elif not all_done and was == "ready":
		quest_state[id] = "active"   # e.g. sold the pelts again

func _objective_done(id: String, obj: Dictionary) -> bool:
	match obj.get("type", ""):
		"collect":
			return Inventory.count(obj["item"]) >= int(obj.get("count", 1))
		"kill", "event":
			return int(progress.get(id, {}).get(obj.get("id", "obj"), 0)) >= int(obj.get("count", 1))
	return false

func objective_text(id: String) -> String:
	var q := Db.get_quest(id)
	var lines: Array[String] = []
	for obj in q.get("objectives", []):
		var have := 0
		var need: int = int(obj.get("count", 1))
		match obj.get("type", ""):
			"collect": have = mini(Inventory.count(obj["item"]), need)
			_: have = mini(int(progress.get(id, {}).get(obj.get("id", "obj"), 0)), need)
		lines.append("  - %s (%d/%d)" % [obj.get("desc", obj.get("id", "")), have, need])
	return "\n".join(lines)

func export_state() -> Dictionary:
	return {"quest_state": quest_state.duplicate(true), "progress": progress.duplicate(true)}

func import_state(data: Dictionary) -> void:
	quest_state = data.get("quest_state", {})
	progress = data.get("progress", {})
