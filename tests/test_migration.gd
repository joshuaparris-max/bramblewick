extends Node

func _ready() -> void:
	print("Starting migration tests...")
	call_deferred("_run_tests")

func _run_tests() -> void:
	var old_save = {
		"version": 1,
		"game_state": {
			"current_map": "village",
			"player_pos": [15, 10],
			"player": {"name": "TestHero"}
		}
	}
	var f = FileAccess.open("user://save.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(old_save))
	f.close()
	
	var res = SaveManager.load_game()
	assert(res == true, "Should load old save")
	assert(GameState.current_map == "village_market", "Should be migrated to village_market")
	assert(GameState.player_pos == Vector2i(4, 4), "Should be migrated to safe pos")
	assert(GameState.player.get("name") == "TestHero", "Should preserve player data")
	
	print("PASS: Migration old save")
	print("ALL MIGRATION TESTS PASSED.")
	get_tree().quit(0)
