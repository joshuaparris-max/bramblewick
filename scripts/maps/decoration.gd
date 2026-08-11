extends Node2D

const TILE := 32

var _type: String
var _color: Color
var _solid: bool

func setup(data: Dictionary) -> void:
	_type = data.get("type", "unknown")
	var pos: Array = data.get("pos", [0, 0])
	position = Vector2(pos[0] * TILE, pos[1] * TILE)
	_solid = data.get("solid", false)
	
	match _type:
		"counter": _color = Color("5a4128")
		"forge": _color = Color("282828")
		"table": _color = Color("684e32")
		"bed": _color = Color("2a3a5a")
		"shelf": _color = Color("3a2f1f")
		"barrel": _color = Color("8a6b4e")
		"crate": _color = Color("7a5e42")
		"anvil": _color = Color("383838")
		"well": _color = Color("404040")
		"cart": _color = Color("605030")
		"sign": _color = Color("7a6a5a")
		"shrine": _color = Color("b3b3d8")
		"pillar": _color = Color("a8a8a8")
		"fence": _color = Color("4a3a2a")
		"hay": _color = Color("d8c878")
		_: _color = Color("ff00ff")

func _ready() -> void:
	var rect := ColorRect.new()
	rect.color = _color
	rect.size = Vector2(TILE, TILE)
	add_child(rect)
	
	if _solid:
		var body := StaticBody2D.new()
		var shape := CollisionShape2D.new()
		var rs := RectangleShape2D.new()
		rs.size = Vector2(TILE, TILE)
		shape.shape = rs
		body.add_child(shape)
		body.position = Vector2(TILE / 2.0, TILE / 2.0)
		add_child(body)
