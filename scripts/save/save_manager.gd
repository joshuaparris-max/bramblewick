extends Node

const SAVE_PATH := "user://save.json"
const VERSION := 2

func save_game() -> void:
	var data := {
		"version": VERSION,
		"game_state": GameState.export_state(),
		"inventory": Inventory.export_state(),
		"quests": QuestManager.export_state(),
	}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		push_error("[Save] cannot write " + SAVE_PATH)
		return
	f.store_string(JSON.stringify(data, "\t"))
	EventBus.game_saved.emit()
	EventBus.toast.emit("Game saved.")

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func load_game() -> bool:
	if not has_save():
		return false
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data: Variant = JSON.parse_string(f.get_as_text())
	if not (data is Dictionary):
		push_error("[Save] corrupt save file")
		return false
	data = migrate_data(data)
	GameState.import_state(data.get("game_state", {}))
	Inventory.import_state(data.get("inventory", {}))
	QuestManager.import_state(data.get("quests", {}))
	EventBus.game_loaded.emit()
	return true

func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

func migrate_data(data: Dictionary) -> Dictionary:
	var v = data.get("version", 1)
	if v < 2:
		if data.has("game_state"):
			var gs = data["game_state"]
			if gs.get("current_map") == "village":
				gs["current_map"] = "village_market"
				gs["player_pos"] = [4, 4] # Safe spawn
		data["version"] = 2
	return data
