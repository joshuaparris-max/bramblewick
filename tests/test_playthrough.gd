extends Node

func _ready():
	print("Starting honest playthrough integration test...")
	var timeout_timer = get_tree().create_timer(30.0)
	timeout_timer.timeout.connect(func(): push_error("FAIL: Overall test timeout"); get_tree().quit(1))
	_run_test()

func require(condition: bool, stage: int, message: String) -> bool:
	if not condition:
		push_error("FAIL: Stage %d - %s" % [stage, message])
		get_tree().quit(1)
		return false
	print("PASS: Stage %d - %s" % [stage, message])
	return true

func wait_frames(n: int):
	for i in range(n):
		await get_tree().process_frame

func wait_seconds(sec: float):
	await get_tree().create_timer(sec).timeout

func push_action(action: String, hold_sec: float = 0.2):
	var ev = InputEventAction.new()
	ev.action = action
	ev.pressed = true
	Input.parse_input_event(ev)
	await wait_seconds(hold_sec)
	ev.pressed = false
	Input.parse_input_event(ev)
	await wait_frames(2)

func _run_test():
	await wait_seconds(0.5)
	
	var scene = get_tree().current_scene
	require(scene != null and scene.name == "TitleScreen", 1, "Title screen rendered")
	
	SceneRouter.goto("create")
	await wait_seconds(0.5)
	scene = get_tree().current_scene
	
	require(scene.name == "CharacterCreation", 2, "New game started")
	scene._name_edit.text = "Hero"
	scene._begin()
	await wait_seconds(0.5)
	scene = get_tree().current_scene
	require(scene.name == "Exploration", 3, "Character creation completed, Exploration loaded")
	
	await wait_seconds(0.5)
	var players = get_tree().get_nodes_in_group("player")
	require(players.size() > 0, 4, "Player spawned in exploration scene")
	var p = players[0]
	
	var start_pos = p.position
	await push_action("move_right", 0.5)
	require(p.position.x > start_pos.x, 5, "Player movement works (moved right via input)")
	
	# Move left into the wall at x=0
	await push_action("move_left", 3.0) 
	var pos1 = p.position
	await push_action("move_left", 0.5)
	require(abs(p.position.x - pos1.x) < 2.0, 6, "Collision behaves sensibly (blocked from moving further left)")
	
	var portals = get_tree().get_nodes_in_group("portal")
	require(portals.size() > 0, 7, "Map has portals to test")
	var portal = portals[0]
	var dest = portal._def["to_map"]
	var prev_map = GameState.current_map
	
	# Simulate entering portal directly as collision
	portal._on_body_entered(p)
	await wait_seconds(1.0)
	scene = get_tree().current_scene
	require(scene.name == "Exploration" and GameState.current_map == dest and GameState.current_map != prev_map, 7, "PORTAL COLLISION-HANDLER INTEGRATION TEST - Map transitions on portal trigger")
	
	# 8-9. Dialogue
	await wait_seconds(0.5)
	var npcs = get_tree().get_nodes_in_group("npc")
	require(npcs.size() > 0, 8, "NPC exists to interact with")
	var npc = npcs[0]

	
	p = get_tree().get_nodes_in_group("player")[0]
	p.position = npc.position
	await push_action("interact", 0.1)
	await wait_seconds(0.5)
	var diag = scene.get_node_or_null("DialogueUI")
	require(diag != null and diag.visible, 8, "NPC interacted via input, UI opened")
	
	await push_action("interact", 0.1)
	await wait_seconds(0.2)
	diag._close()
	await wait_seconds(0.2)
	require(not diag.visible, 9, "Dialogue closed")
	
	# 10. Quest
	QuestManager.start_quest("q_silent_mine")
	require(QuestManager.state_of("q_silent_mine") == "active", 10, "QUEST-STATE INTEGRATION TESTS - Quest accepted")
	
	# 11. Quest objective
	EventBus.monster_killed.emit("spider_matron")
	require(QuestManager.state_of("q_silent_mine") == "ready", 11, "QUEST-STATE INTEGRATION TESTS - Quest objective progressed to ready")
	
	# 12. Combat
	GameState.pending_encounter = {"monster_id": "wolf", "spawn_key": ""}
	SceneRouter.goto("combat")
	await wait_seconds(1.0)
	scene = get_tree().current_scene
	require(scene.name == "Combat", 12, "Combat entered")
	
	var initial_enemy_hp = scene.m_hp
	var initial_player_hp = GameState.player.hp
	var hit_safety = 10
	while scene.m_hp >= initial_enemy_hp and hit_safety > 0:
		if not scene._busy:
			scene._attack()
		await wait_seconds(1.0)
		hit_safety -= 1
	require(scene.m_hp < initial_enemy_hp, 13, "COMBAT-LOGIC INTEGRATION TESTS - Enemy HP reduced")
	
	await wait_seconds(2.0)
	require(scene._round > 1 or scene.m_hp == 0, 14, "Enemy turn/Damage states function")
	
	# keep attacking until dead
	var safety = 20
	while scene.m_hp > 0 and safety > 0:
		safety -= 1
		if not scene._busy:
			scene._attack()
		await wait_seconds(0.5)
	
	require(scene.m_hp <= 0, 15, "Enemy HP reaches zero through combat processing")
	await wait_seconds(2.5) 
	scene = get_tree().current_scene
	require(scene.name == "Exploration", 15, "Combat victory returns to intended scene")
	
	QuestManager.turn_in("q_silent_mine")
	require(QuestManager.state_of("q_silent_mine") == "done", 16, "Quest completed successfully")
	require(Inventory.gold >= 50, 17, "Vertical slice completion reward is granted (50 gold)")
	
	GameState.player.name = "SaveTest"
	GameState.current_map = "village"
	SaveManager.save_game()
	require(FileAccess.file_exists("user://save.json"), 18, "Saving works")
	
	GameState.player.name = "Empty"
	GameState.current_map = "none"
	SaveManager.load_game()
	require(GameState.player.name == "SaveTest" and GameState.current_map == "village", 21, "Loading restores saved state")
	
	SceneRouter.goto("title")
	await wait_seconds(0.5)
	scene = get_tree().current_scene
	require(scene.name == "TitleScreen", 22, "Restart behaviour works")
	
	print("ALL PLAYTHROUGH STAGES PASSED.")
	get_tree().quit(0)

