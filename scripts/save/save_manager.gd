extends Node
## MODULE: Save/Load
## PURPOSE: Serialises game state to user://save.json and restores it.
##   It only calls export_state()/import_state() on each owning module -
##   it never reaches inside them.
## SAFE TO EDIT: add modules to the gather/restore lists; bump VERSION when
##   the format changes and add a migration in _migrate().
## DANGEROUS: removing VERSION checks; writing partial saves.
## PUBLIC API: save_game(), load_game() -> bool, has_save(), delete_save()
## FUTURE: multiple slots, autosave on map change, cloud sync, save screenshots.

const SAVE_PATH := "user://save.json"
const VERSION := 1

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
	data = _migrate(data)
	GameState.import_state(data.get("game_state", {}))
	Inventory.import_state(data.get("inventory", {}))
	QuestManager.import_state(data.get("quests", {}))
	EventBus.game_loaded.emit()
	return true

func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

func _migrate(data: Dictionary) -> Dictionary:
	# When VERSION bumps, upgrade old saves here instead of breaking them.
	return data
