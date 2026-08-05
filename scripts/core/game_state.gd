extends Node
## MODULE: GameState (core)
## PURPOSE: Owns the player record, world flags, reputation, current map/position,
##   cleared encounters, and pending combat handoff. The single source of truth.
## SAFE TO EDIT: add new fields (also add them to export_state/import_state!),
##   tweak level-up gains.
## DANGEROUS: renaming player dict keys ("hp","stats"...) - combat, UI and
##   save files all read them. Never let UI write these directly; add a method.
## PUBLIC API:
##   new_game(class_id, name), player (Dictionary, read-only by convention)
##   set_flag(name, v:=true), get_flag(name)
##   change_hp(delta), heal_full(), add_xp(amount)
##   attack_bonus(), damage_string(), recalc_derived()
##   change_reputation(faction, amount)
##   mark_spawn_cleared(key), is_spawn_cleared(key)
##   export_state() / import_state(data)  (used by SaveManager)
## FUTURE: party members array, time-of-day, difficulty settings.

var player: Dictionary = {}
var flags: Dictionary = {}
var reputation: Dictionary = {}
var current_map: String = "village_market"
var player_pos: Vector2i = Vector2i(2, 2)
var cleared_spawns: Dictionary = {}
var pending_encounter: Dictionary = {}   # {"monster_id":..,"spawn_key":..} set before combat

func new_game(class_id: String, pname: String) -> void:
	var c := Db.get_class_def(class_id)
	flags = {}; reputation = {}; cleared_spawns = {}; pending_encounter = {}
	player = {
		"name": pname, "class_id": class_id,
		"stats": c["stats"].duplicate(),
		"level": 1, "xp": 0,
		"hp_max": 0, "hp": 0, "ac": 10,
		"skill_profs": c.get("skill_profs", []),
		"abilities": c.get("abilities", []),
		"slots_max": c.get("slots", 0), "slots": c.get("slots", 0),
	}
	Inventory.reset(c)
	QuestManager.reset()
	recalc_derived()
	player["hp_max"] = c["base_hp"] + Rules.ability_mod(player["stats"]["CON"])
	player["hp"] = player["hp_max"]
	current_map = "village_market"
	player_pos = Vector2i(c.get("start_pos", [3, 5])[0], c.get("start_pos", [3, 5])[1])
	EventBus.state_changed.emit()

func recalc_derived() -> void:
	# AC and attack come from class base + equipped items. UI never computes rules.
	var c := Db.get_class_def(player.get("class_id", ""))
	if c.is_empty(): return
	var ac: int = 10 + Rules.ability_mod(player["stats"]["DEX"])
	var armour := Inventory.equipped_item("armour")
	if not armour.is_empty():
		ac = int(armour.get("ac", 10))
		if armour.get("dex_cap", true):
			ac += mini(Rules.ability_mod(player["stats"]["DEX"]), int(armour.get("max_dex", 2)))
	if Inventory.equipped_id("shield") != "":
		ac += 2
	player["ac"] = ac
	EventBus.state_changed.emit()

func weapon() -> Dictionary:
	var w := Inventory.equipped_item("weapon")
	if w.is_empty():
		w = {"name": "Fists", "damage": "1d2", "stat": "STR", "bonus": 0}
	return w

func attack_bonus() -> int:
	var w := weapon()
	return Rules.ability_mod(player["stats"].get(w.get("stat", "STR"), 10)) \
		+ Rules.proficiency(player["level"]) + int(w.get("bonus", 0))

func damage_string() -> String:
	var w := weapon()
	var m := Rules.ability_mod(player["stats"].get(w.get("stat", "STR"), 10)) + int(w.get("bonus", 0))
	return w.get("damage", "1d2") + ("+%d" % m if m >= 0 else str(m))

func change_hp(delta: int) -> void:
	player["hp"] = clampi(player["hp"] + delta, 0, player["hp_max"])
	EventBus.state_changed.emit()
	if player["hp"] <= 0:
		EventBus.player_died.emit()

func heal_full() -> void:
	player["hp"] = player["hp_max"]
	player["slots"] = player["slots_max"]
	EventBus.state_changed.emit()

func add_xp(amount: int) -> void:
	player["xp"] += amount
	EventBus.toast.emit("+%d XP" % amount)
	while player["level"] < Rules.XP_THRESHOLDS.size() - 1 \
			and player["xp"] >= Rules.xp_threshold(player["level"]):
		_level_up()
	EventBus.state_changed.emit()

func _level_up() -> void:
	player["level"] += 1
	var c := Db.get_class_def(player["class_id"])
	var gain: int = maxi(1, Rules.roll(c.get("hit_die", 8)) + Rules.ability_mod(player["stats"]["CON"]))
	player["hp_max"] += gain
	player["hp"] = player["hp_max"]
	if player["slots_max"] > 0:
		player["slots_max"] += 1
		player["slots"] = player["slots_max"]
	EventBus.player_leveled.emit(player["level"])
	EventBus.toast.emit("Level %d! Max HP +%d" % [player["level"], gain])

func set_flag(flag_name: String, v: bool = true) -> void:
	flags[flag_name] = v

func get_flag(flag_name: String) -> bool:
	return flags.get(flag_name, false)

func change_reputation(faction: String, amount: int) -> void:
	reputation[faction] = int(reputation.get(faction, 0)) + amount
	EventBus.reputation_changed.emit(faction, amount)

func mark_spawn_cleared(key: String) -> void:
	cleared_spawns[key] = true

func is_spawn_cleared(key: String) -> bool:
	return cleared_spawns.get(key, false)

func export_state() -> Dictionary:
	return {
		"player": player.duplicate(true), "flags": flags.duplicate(true),
		"reputation": reputation.duplicate(true),
		"current_map": current_map, "player_pos": [player_pos.x, player_pos.y],
		"cleared_spawns": cleared_spawns.duplicate(true),
	}

func import_state(data: Dictionary) -> void:
	player = data.get("player", {})
	flags = data.get("flags", {})
	reputation = data.get("reputation", {})
	current_map = data.get("current_map", "village_market")
	var p: Array = data.get("player_pos", [2, 2])
	player_pos = Vector2i(int(p[0]), int(p[1]))
	cleared_spawns = data.get("cleared_spawns", {})
	EventBus.state_changed.emit()
