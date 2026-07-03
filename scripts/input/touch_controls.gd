extends CanvasLayer
## MODULE: Input (touch placeholder)
## PURPOSE: On-screen d-pad + interact button for phones/tablets. It presses
##   the SAME input actions as keyboard/gamepad, so the rest of the game
##   doesn't know touch exists. Hidden automatically on non-touch devices.
## SAFE TO EDIT: layout/size, replace Buttons with TouchScreenButton + art,
##   add a virtual joystick.
## FUTURE: proper virtual joystick, opacity setting, left/right hand mode.

func _ready() -> void:
	layer = 6
	visible = DisplayServer.is_touchscreen_available()
	var grid := GridContainer.new()
	grid.columns = 3
	grid.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	grid.offset_left = -190.0
	grid.offset_top = -190.0
	grid.offset_right = -16.0
	grid.offset_bottom = -16.0
	add_child(grid)
	var cells := ["", "move_up", "", "move_left", "", "move_right", "", "move_down", ""]
	for action in cells:
		if action == "":
			grid.add_child(Control.new())
		else:
			grid.add_child(_hold_button(action))
	var interact := _hold_button("interact")
	interact.text = "A"
	interact.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	interact.offset_left = 20.0
	interact.offset_top = -90.0
	interact.offset_right = 90.0
	interact.offset_bottom = -20.0
	add_child(interact)

func _hold_button(action: String) -> Button:
	var b := Button.new()
	b.text = {"move_up": "^", "move_down": "v", "move_left": "<", "move_right": ">"}.get(action, action)
	b.custom_minimum_size = Vector2(54, 54)
	b.button_down.connect(func(): Input.action_press(action))
	b.button_up.connect(func(): Input.action_release(action))
	return b
