extends Node

var _stage := 1
var test_scene: Node2D

func _ready() -> void:
	print("Starting quest integration tests...")
	call_deferred("_run_tests")

func _run_tests() -> void:
	print("Testing q_lost_delivery...")
	GameState.new_game("fighter", "Hero")
	GameState.current_map = "village_market"
	QuestManager.start_quest("q_lost_delivery")
	Inventory.add("kael_package", 1)
	assert(QuestManager.is_ready("q_lost_delivery"), "Objective should be ready")
	QuestManager.turn_in("q_lost_delivery")
	assert(QuestManager.state_of("q_lost_delivery") == "done", "Quest should be complete")
	assert(Inventory.count("kael_package") == 0, "Package should be consumed")
	print("PASS: q_lost_delivery")
	
	print("Testing q_marsh_roots...")
	GameState.new_game("fighter", "Hero")
	QuestManager.start_quest("q_marsh_roots")
	Inventory.add("marsh_root", 3)
	assert(QuestManager.is_ready("q_marsh_roots"), "Objective should be ready")
	QuestManager.turn_in("q_marsh_roots")
	assert(QuestManager.state_of("q_marsh_roots") == "done", "Quest should be complete")
	assert(Inventory.count("marsh_root") == 0, "Roots should be consumed")
	print("PASS: q_marsh_roots")

	print("Testing q_mill_trouble...")
	GameState.new_game("fighter", "Hero")
	QuestManager.start_quest("q_mill_trouble")
	for i in range(3):
		EventBus.monster_killed.emit("spider")
	assert(QuestManager.is_ready("q_mill_trouble"), "Objective should be ready")
	QuestManager.turn_in("q_mill_trouble")
	assert(QuestManager.state_of("q_mill_trouble") == "done", "Quest should be complete")
	print("PASS: q_mill_trouble")

	print("Testing q_empty_house...")
	GameState.new_game("fighter", "Hero")
	QuestManager.start_quest("q_empty_house")
	GameState.set_flag("found_vorn", true)
	EventBus.dialogue_event.emit("found_vorn")
	assert(QuestManager.is_ready("q_empty_house"), "Objective should be ready")
	QuestManager.turn_in("q_empty_house")
	assert(QuestManager.state_of("q_empty_house") == "done", "Quest should be complete")
	print("PASS: q_empty_house")
	
	print("ALL QUEST TESTS PASSED.")
	get_tree().quit(0)
