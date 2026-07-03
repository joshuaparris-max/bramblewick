extends Node
## MODULE: Input (bindings)
## PURPOSE: Defines all input actions IN CODE at startup, keyboard + gamepad,
##   so bindings are readable and diff-able instead of buried in project.godot.
## SAFE TO EDIT: change keys/buttons, add actions (then use them via
##   Input.is_action_* anywhere).
## DANGEROUS: renaming actions - player controller, UI and touch controls use
##   these exact names.
## ACTIONS: move_left/right/up/down, interact, open_inventory, open_journal,
##   debug_toggle, ui_back
## FUTURE: rebindable controls menu (InputMap makes this easy).

func _ready() -> void:
	_action("move_left", [KEY_A, KEY_LEFT], JOY_BUTTON_DPAD_LEFT, JOY_AXIS_LEFT_X, -1.0)
	_action("move_right", [KEY_D, KEY_RIGHT], JOY_BUTTON_DPAD_RIGHT, JOY_AXIS_LEFT_X, 1.0)
	_action("move_up", [KEY_W, KEY_UP], JOY_BUTTON_DPAD_UP, JOY_AXIS_LEFT_Y, -1.0)
	_action("move_down", [KEY_S, KEY_DOWN], JOY_BUTTON_DPAD_DOWN, JOY_AXIS_LEFT_Y, 1.0)
	_action("interact", [KEY_E, KEY_SPACE], JOY_BUTTON_A)
	_action("open_inventory", [KEY_I], JOY_BUTTON_Y)
	_action("open_journal", [KEY_J], JOY_BUTTON_X)
	_action("ui_back", [KEY_ESCAPE], JOY_BUTTON_B)
	_action("debug_toggle", [KEY_F1])

func _action(action_name: String, keys: Array, joy_button: int = -1,
		joy_axis: int = -1, axis_value: float = 0.0) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	for k in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = k
		InputMap.action_add_event(action_name, ev)
	if joy_button >= 0:
		var jb := InputEventJoypadButton.new()
		jb.button_index = joy_button
		InputMap.action_add_event(action_name, jb)
	if joy_axis >= 0:
		var ja := InputEventJoypadMotion.new()
		ja.axis = joy_axis
		ja.axis_value = axis_value
		InputMap.action_add_event(action_name, ja)
