extends Node
## MODULE: Inventory & Items
## PURPOSE: Owns everything the player carries: items, equipment slots, gold.
##   Item DEFINITIONS live in data/items/items.json; this holds player copies.
## SAFE TO EDIT: add equipment slots (also update recalc in GameState),
##   add consumable effect types in use_item().
## DANGEROUS: gold/add/remove signatures - dialogue, quests and shops call them.
## PUBLIC API:
##   add(item_id, count:=1), remove(item_id, count:=1) -> bool, count(item_id)
##   gold, add_gold(n), spend_gold(n) -> bool
##   equip(item_id), unequip(slot), equipped_id(slot), equipped_item(slot)
##   use_item(item_id) -> bool (consumables)
##   export_state()/import_state(data)
## FUTURE: weight, stacking rules, item rarity, crafting, containers.

var items: Dictionary = {}          # id -> count
var equipment: Dictionary = {"weapon": "", "armour": "", "shield": ""}
var gold: int = 0

func reset(class_def: Dictionary) -> void:
	items = {}; equipment = {"weapon": "", "armour": "", "shield": ""}
	gold = int(class_def.get("gold", 10))
	for id in class_def.get("starting_items", {}):
		add(id, int(class_def["starting_items"][id]))
	for slot in class_def.get("starting_equipment", {}):
		var id: String = class_def["starting_equipment"][slot]
		add(id)
		equip(id)
	EventBus.gold_changed.emit(gold)

func add(item_id: String, n: int = 1) -> void:
	if Db.get_item(item_id).is_empty():
		push_warning("[Inventory] unknown item: " + item_id)
		return
	items[item_id] = int(items.get(item_id, 0)) + n
	EventBus.item_gained.emit(item_id, n)
	EventBus.state_changed.emit()

func remove(item_id: String, n: int = 1) -> bool:
	if count(item_id) < n:
		return false
	items[item_id] -= n
	if items[item_id] <= 0:
		items.erase(item_id)
		for slot in equipment:
			if equipment[slot] == item_id:
				equipment[slot] = ""
	EventBus.item_lost.emit(item_id, n)
	EventBus.state_changed.emit()
	return true

func count(item_id: String) -> int:
	return int(items.get(item_id, 0))

func add_gold(n: int) -> void:
	gold += n
	EventBus.gold_changed.emit(gold)
	EventBus.state_changed.emit()

func spend_gold(n: int) -> bool:
	if gold < n:
		return false
	gold -= n
	EventBus.gold_changed.emit(gold)
	EventBus.state_changed.emit()
	return true

func equip(item_id: String) -> void:
	var it := Db.get_item(item_id)
	var slot: String = it.get("slot", "")
	if slot == "" or count(item_id) <= 0:
		return
	equipment[slot] = item_id
	EventBus.equipment_changed.emit()
	GameState.recalc_derived()

func unequip(slot: String) -> void:
	equipment[slot] = ""
	EventBus.equipment_changed.emit()
	GameState.recalc_derived()

func equipped_id(slot: String) -> String:
	return equipment.get(slot, "")

func equipped_item(slot: String) -> Dictionary:
	return Db.get_item(equipped_id(slot))

func use_item(item_id: String) -> bool:
	var it := Db.get_item(item_id)
	if it.get("type", "") != "consumable" or count(item_id) <= 0:
		return false
	match it.get("effect", ""):
		"heal":
			if GameState.player["hp"] >= GameState.player["hp_max"]:
				EventBus.toast.emit("Already at full health.")
				return false
			var h: int = Rules.roll_dice(it.get("amount", "2d4+2"))
			GameState.change_hp(h)
			EventBus.toast.emit("+%d HP" % h)
		_:
			return false
	remove(item_id)
	return true

func export_state() -> Dictionary:
	return {"items": items.duplicate(true), "equipment": equipment.duplicate(true), "gold": gold}

func import_state(data: Dictionary) -> void:
	items = data.get("items", {})
	equipment = data.get("equipment", {"weapon": "", "armour": "", "shield": ""})
	gold = int(data.get("gold", 0))
	EventBus.state_changed.emit()
