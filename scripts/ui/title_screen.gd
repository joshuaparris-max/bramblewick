extends Control
## MODULE: UI (title screen)
## PURPOSE: Entry menu: New Game, Continue (if a save exists), Quit - centred
##   over a procedurally drawn night-forest vista (no art assets required).
## SAFE TO EDIT: styling, background colours/shapes in Backdrop, credits.
## FUTURE: version label, options menu, parallax on mouse move.

func _ready() -> void:
	# Root controls under the Window don't inherit its size automatically -
	# fit to the viewport explicitly or every child lays out against (0,0).
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_background()
	_build_menu()

# ---------- menu ----------
func _build_menu() -> void:
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.03, 0.025, 0.05, 0.74)
	style.set_corner_radius_all(10)
	style.set_border_width_all(1)
	style.border_color = Color("e8b45a4d")
	style.content_margin_left = 48.0
	style.content_margin_right = 48.0
	style.content_margin_top = 32.0
	style.content_margin_bottom = 36.0
	panel.add_theme_stylebox_override("panel", style)
	center.add_child(panel)

	var v := VBoxContainer.new()
	v.custom_minimum_size = Vector2(360, 0)
	v.add_theme_constant_override("separation", 10)
	panel.add_child(v)

	var t := Label.new()
	t.text = "SHADOW OVER BRAMBLEWICK"
	t.add_theme_font_size_override("font_size", 38)
	t.add_theme_color_override("font_color", Color("e8b45a"))
	t.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	t.add_theme_constant_override("shadow_offset_x", 0)
	t.add_theme_constant_override("shadow_offset_y", 3)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(t)

	var s := Label.new()
	s.text = "The mine has gone silent.\n"
	s.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	s.add_theme_color_override("font_color", Color("8a7a62"))
	v.add_child(s)

	_btn(v, "New Adventure", func(): SceneRouter.goto("create"))
	if SaveManager.has_save():
		_btn(v, "Continue", func():
			if SaveManager.load_game():
				SceneRouter.goto("explore"))
	_btn(v, "Quit", func(): get_tree().quit())

func _btn(parent: Node, text: String, fn: Callable) -> void:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, 44)
	b.pressed.connect(fn)
	parent.add_child(b)

# ---------- background ----------
func _build_background() -> void:
	var sky := TextureRect.new()
	sky.set_anchors_preset(Control.PRESET_FULL_RECT)
	sky.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sky.stretch_mode = TextureRect.STRETCH_SCALE
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.55, 0.85, 1.0])
	g.colors = PackedColorArray([Color("0b0a16"), Color("18121e"), Color("2a1c22"), Color("33231e")])
	var sky_tex := GradientTexture2D.new()
	sky_tex.gradient = g
	sky_tex.fill_from = Vector2(0, 0)
	sky_tex.fill_to = Vector2(0, 1)
	sky.texture = sky_tex
	add_child(sky)

	add_child(Backdrop.new())
	_add_fireflies()

	var vig := TextureRect.new()
	vig.set_anchors_preset(Control.PRESET_FULL_RECT)
	vig.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	vig.stretch_mode = TextureRect.STRETCH_SCALE
	var vg := Gradient.new()
	vg.offsets = PackedFloat32Array([0.0, 0.55, 1.0])
	vg.colors = PackedColorArray([Color(0, 0, 0, 0), Color(0, 0, 0, 0.06), Color(0, 0, 0, 0.52)])
	var vig_tex := GradientTexture2D.new()
	vig_tex.gradient = vg
	vig_tex.width = 256
	vig_tex.height = 256
	vig_tex.fill = GradientTexture2D.FILL_RADIAL
	vig_tex.fill_from = Vector2(0.5, 0.45)
	vig_tex.fill_to = Vector2(0.5, 1.15)
	vig.texture = vig_tex
	add_child(vig)

func _add_fireflies() -> void:
	var s := get_viewport_rect().size
	var p := CPUParticles2D.new()
	p.amount = 26
	p.lifetime = 7.0
	p.preprocess = 7.0
	p.position = Vector2(s.x * 0.5, s.y * 0.8)
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(s.x * 0.55, s.y * 0.18)
	p.direction = Vector2(0, -1)
	p.spread = 180.0
	p.gravity = Vector2(0, -4)
	p.initial_velocity_min = 2.0
	p.initial_velocity_max = 10.0
	p.scale_amount_min = 1.2
	p.scale_amount_max = 2.6
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.2, 0.8, 1.0])
	ramp.colors = PackedColorArray([Color("e8b45a00"), Color("e8b45ad9"), Color("e8b45ad9"), Color("e8b45a00")])
	p.color_ramp = ramp
	add_child(p)

## Draws the static vista: stars, moon, mountain ridges, mist and pine
## silhouettes. Seeded so the scene is identical every boot.
class Backdrop extends Node2D:
	var rng := RandomNumberGenerator.new()

	func _ready() -> void:
		get_viewport().size_changed.connect(queue_redraw)

	func _draw() -> void:
		rng.seed = 1347
		var s := get_viewport_rect().size
		_stars(s)
		_moon(s)
		_ridge(s, 0.50, 42.0, Color("221a2e"))
		draw_rect(Rect2(0, s.y * 0.56, s.x, 18), Color(0.54, 0.58, 0.72, 0.05))
		_ridge(s, 0.60, 28.0, Color("191420"))
		draw_rect(Rect2(0, s.y * 0.68, s.x, 26), Color(0.54, 0.58, 0.72, 0.07))
		_trees(s, 0.88, 70.0, 130.0, Color("100e16"))
		draw_rect(Rect2(0, s.y * 0.90, s.x, 14), Color(0.54, 0.58, 0.72, 0.05))
		_trees(s, 1.01, 120.0, 200.0, Color("0a0910"))

	func _stars(s: Vector2) -> void:
		for i in 110:
			var pos := Vector2(rng.randf_range(0, s.x), rng.randf_range(0, s.y * 0.52))
			var warm := rng.randf() < 0.25
			var c := Color("e8d8b3") if warm else Color("d8dce8")
			c.a = rng.randf_range(0.15, 0.85)
			draw_circle(pos, rng.randf_range(0.6, 1.7), c)

	func _moon(s: Vector2) -> void:
		var center := Vector2(s.x * 0.74, s.y * 0.22)
		var r := minf(s.x, s.y) * 0.065
		for i in 5:
			var glow := Color("e8e0c4")
			glow.a = 0.028 + 0.016 * i
			draw_circle(center, r * (2.6 - i * 0.35), glow)
		draw_circle(center, r, Color("e6dfc4"))
		var crater := Color("c9bfa2", 0.55)
		draw_circle(center + Vector2(-r * 0.3, -r * 0.15), r * 0.22, crater)
		draw_circle(center + Vector2(r * 0.28, r * 0.3), r * 0.15, crater)
		draw_circle(center + Vector2(r * 0.1, -r * 0.42), r * 0.11, crater)

	func _ridge(s: Vector2, base_frac: float, amp: float, color: Color) -> void:
		var pts := PackedVector2Array()
		pts.append(Vector2(-4, s.y))
		var y := s.y * base_frac
		var steps := 16
		for i in steps + 1:
			y = clampf(y + rng.randf_range(-amp, amp),
				s.y * (base_frac - 0.13), s.y * (base_frac + 0.06))
			pts.append(Vector2(s.x * i / steps, y))
		pts.append(Vector2(s.x + 4, s.y))
		draw_colored_polygon(pts, color)

	func _trees(s: Vector2, base_frac: float, h_min: float, h_max: float, color: Color) -> void:
		var y0 := s.y * base_frac
		if y0 < s.y:
			draw_rect(Rect2(0, y0, s.x, s.y - y0), color)
		var x := -20.0
		while x < s.x + 30.0:
			var h := rng.randf_range(h_min, h_max)
			var w := h * rng.randf_range(0.30, 0.44)
			draw_colored_polygon(PackedVector2Array([
				Vector2(x, y0 - h), Vector2(x - w, y0 + 2), Vector2(x + w, y0 + 2)]), color)
			draw_colored_polygon(PackedVector2Array([
				Vector2(x, y0 - h * 1.16), Vector2(x - w * 0.62, y0 - h * 0.42),
				Vector2(x + w * 0.62, y0 - h * 0.42)]), color)
			x += w * rng.randf_range(1.1, 1.9)
