extends Node2D
## MODULE: Map & Exploration (scene glue)
## PURPOSE: Loads the current map (from GameState.current_map), asks MapBuilder
##   to construct it, spawns the player, and attaches the UI layers (HUD,
##   dialogue UI, touch controls, debug panel). Thin glue - no rules here.
## SAFE TO EDIT: which UI layers get attached; ambience per map.
## DANGEROUS: building tiles or dialogue logic inline here - use the modules.
## FUTURE: streaming larger maps, minimap, fast travel.

const TILE := 32

func _ready() -> void:
	var map_data := Db.get_map(GameState.current_map)
	assert(not map_data.is_empty(), "Unknown map: " + GameState.current_map)
	MapBuilder.build(map_data, self)
	Presentation.dress(map_data, self)
	var player: CharacterBody2D = load("res://scenes/player/player.tscn").instantiate()
	player.position = Vector2(GameState.player_pos.x * TILE + TILE / 2.0,
		GameState.player_pos.y * TILE + TILE / 2.0)
	add_child(player)
	add_child(load("res://scenes/ui/hud.tscn").instantiate())
	add_child(load("res://scenes/dialogue/dialogue_ui.tscn").instantiate())
	add_child(load("res://scenes/ui/touch_controls.tscn").instantiate())
	add_child(load("res://scenes/ui/debug_panel.tscn").instantiate())
	AudioManager.play_music(GameState.current_map)
	EventBus.map_loaded.emit(GameState.current_map)
