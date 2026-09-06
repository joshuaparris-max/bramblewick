extends Node

func _ready() -> void:
	print("Starting world/content quest integration tests...")
	call_deferred("_run_tests")

func _run_tests() -> void:
	GameState.new_game("fighter", "Hero")
	
	# LOST DELIVERY
	print("Testing q_lost_delivery...")
	QuestManager.start_quest("q_lost_delivery")
	assert(QuestManager.state_of("q_lost_delivery") == "active", "Quest should be active")
	Inventory.add("kael_package")
	assert(QuestManager.state_of("q_lost_delivery") == "ready", "Quest should be ready after collecting item")
	QuestManager.turn_in("q_lost_delivery")
	assert(QuestManager.state_of("q_lost_delivery") == "done", "Quest should be done")
	
	# APOTHECARY'S INGREDIENTS
	print("Testing q_marsh_roots...")
	QuestManager.start_quest("q_marsh_roots")
	assert(QuestManager.state_of("q_marsh_roots") == "active", "Quest should be active")
	Inventory.add("marsh_root", 3)
	assert(QuestManager.state_of("q_marsh_roots") == "ready", "Quest should be ready after collecting 3 roots")
	QuestManager.turn_in("q_marsh_roots")
	assert(QuestManager.state_of("q_marsh_roots") == "done", "Quest should be done")

	# TROUBLE AT THE MILL
	print("Testing q_mill_trouble...")
	QuestManager.start_quest("q_mill_trouble")
	assert(QuestManager.state_of("q_mill_trouble") == "active", "Quest should be active")
	EventBus.monster_killed.emit("spider")
	EventBus.monster_killed.emit("spider")
	EventBus.monster_killed.emit("spider")
	assert(QuestManager.state_of("q_mill_trouble") == "ready", "Quest should be ready after killing 3 spiders")
	QuestManager.turn_in("q_mill_trouble")
	assert(QuestManager.state_of("q_mill_trouble") == "done", "Quest should be done")

	# EMPTY HOUSE
	print("Testing q_empty_house...")
	QuestManager.start_quest("q_empty_house")
	assert(QuestManager.state_of("q_empty_house") == "active", "Quest should be active")
	EventBus.dialogue_event.emit("found_vorn")
	assert(QuestManager.state_of("q_empty_house") == "ready", "Quest should be ready after finding Vorn")
	QuestManager.turn_in("q_empty_house")
	assert(QuestManager.state_of("q_empty_house") == "done", "Quest should be done")

	print("ALL QUEST CONTENT VERIFIED.")
	get_tree().quit(0)
