extends Node
func _ready():
	var test = load("res://tests/test_playthrough.tscn").instantiate()
	get_tree().root.call_deferred("add_child", test)
	get_tree().current_scene = self # ensure we are the one replaced
	SceneRouter.goto("title")

