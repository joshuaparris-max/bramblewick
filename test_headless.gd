extends SceneTree

func _init() -> void:
	print("Running headless test...")
	var main_scene = load("res://scenes/main/main.tscn")
	if main_scene == null:
		push_error("Failed to load main scene")
		quit(1)
		return
	
	print("Main scene loads.")
	var inst = main_scene.instantiate()
	root.add_child(inst)
	print("Main scene instantiated.")
	
	# Create a timer to allow Db to load since it might take a frame
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
	timer.one_shot = true
	root.add_child(timer)
	timer.timeout.connect(self._on_timeout)

func _on_timeout() -> void:
	var db_node = root.get_node("/root/Db")
	if db_node == null:
		push_error("Db autoload missing!")
		quit(1)
		return
		
	if db_node.maps.size() == 0:
		push_error("No maps loaded!")
		quit(1)
		return
		
	print("Data loaded: ", db_node.maps.size(), " maps.")
	print("Test passed successfully.")
	quit(0)

