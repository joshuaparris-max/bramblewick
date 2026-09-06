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
		},
		"inventory": {"items": {"potion": 1}},
		"quests": {"quest_state": {"q_marsh_roots": "active"}},
		"cleared_spawns": {"goblin_1": true}
	}
	
	var migrated = SaveManager.migrate_data(old_save)
	
	var gs = migrated.get("game_state", {})
	assert(migrated.get("version") == 2, "Should bump version to 2")
	assert(gs.get("current_map") == "village_market", "Should be migrated to village_market")
	assert(gs.get("player_pos") == [4, 4], "Should be migrated to safe pos")
	assert(gs.get("player", {}).get("name") == "TestHero", "Should preserve player data")
	assert(migrated.get("inventory", {}).get("items", {}).get("potion") == 1, "Should preserve inventory")
	assert(migrated.get("quests", {}).get("quest_state", {}).get("q_marsh_roots") == "active", "Should preserve quest state")
	assert(migrated.get("cleared_spawns", {}).get("goblin_1") == true, "Should preserve cleared spawns")
	
	print("PASS: Migration old save dictionary")
	print("ALL MIGRATION TESTS PASSED.")
	get_tree().quit(0)
