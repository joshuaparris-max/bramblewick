class_name TokenIcon
extends Node2D
## MODULE: Graphics (map tokens)
## PURPOSE: Roll20-style circular tokens for the player, NPCs and monsters,
##   drawn procedurally - ringed disc, drop shadow, vector portrait. If a file
##   res://art/tokens/<token_id>.png exists it is drawn INSTEAD, so real token
##   art can be dropped in later without touching code.
## SAFE TO EDIT: everything - add portrait kinds in _portrait(), tweak colours.
## PUBLIC API: TokenIcon.create(kind, token_id, base_color, ring_color, radius)
##   Portrait kinds: bust, bust_hood, bust_bun, bust_cap, bandit, knight,
##   cleric, ghost, skull, skull_crown, skull_helm, wolf, wolf_alpha, spider,
##   flame, shambler.

var kind := "bust"
var token_id := ""
var base_color := Color("7fa05a")
var ring_color := Color("b8b4a8")
var radius := 13.0
var _tex: Texture2D = null

static func create(p_kind: String, p_id: String, p_base: Color,
		p_ring: Color, p_radius: float) -> TokenIcon:
	var t: TokenIcon = TokenIcon.new()
	t.kind = p_kind
	t.token_id = p_id
	t.base_color = p_base
	t.ring_color = p_ring
	t.radius = p_radius
	var path := "res://art/tokens/%s.png" % p_id
	if ResourceLoader.exists(path):
		t._tex = load(path)
	return t

func _draw() -> void:
	var r := radius
	if _tex != null:
		draw_texture_rect(_tex, Rect2(-r - 2, -r - 2, (r + 2) * 2, (r + 2) * 2), false)
		return
	draw_circle(Vector2(1.5, 2.5), r + 2.6, Color(0, 0, 0, 0.4), true, -1.0, true)
	draw_circle(Vector2.ZERO, r + 2.6, ring_color.darkened(0.35), true, -1.0, true)
	draw_circle(Vector2.ZERO, r + 1.3, ring_color, true, -1.0, true)
	var bg := base_color.darkened(0.62)
	draw_circle(Vector2.ZERO, r, bg, true, -1.0, true)
	var sheen := base_color.lightened(0.35)
	sheen.a = 0.12
	draw_circle(Vector2(-r * 0.25, -r * 0.3), r * 0.8, sheen, true, -1.0, true)
	_portrait(r, base_color.lightened(0.22), bg.darkened(0.4))
	draw_arc(Vector2.ZERO, r, 0, TAU, 48, Color(0, 0, 0, 0.5), 1.2, true)

# ---------- portraits ----------
func _portrait(r: float, pc: Color, dark: Color) -> void:
	match kind:
		"skull": _skull(r, pc, dark)
		"skull_crown":
			_skull(r, pc, dark)
			_poly(r, [[-0.34, -0.44], [-0.34, -0.74], [-0.17, -0.54], [0, -0.8],
				[0.17, -0.54], [0.34, -0.74], [0.34, -0.44]], Color("e8c04a"))
		"skull_helm":
			_skull(r, pc, dark)
			_poly(r, [[-0.42, -0.52], [0.42, -0.52], [0.42, -0.3], [-0.42, -0.3]], pc.darkened(0.45))
			_poly(r, [[-0.05, -0.3], [0.05, -0.3], [0.05, 0.06], [-0.05, 0.06]], pc.darkened(0.45))
		"wolf": _wolf(r, pc, dark, false)
		"wolf_alpha": _wolf(r, pc, dark, true)
		"spider": _spider(r, pc)
		"flame":
			_poly(r, [[0, -0.72], [0.22, -0.32], [0.4, 0.05], [0.32, 0.42], [0, 0.6],
				[-0.32, 0.42], [-0.4, 0.05], [-0.22, -0.32]], pc)
			_poly(r, [[0, -0.28], [0.18, 0.12], [0.12, 0.38], [0, 0.46],
				[-0.12, 0.38], [-0.18, 0.12]], pc.lightened(0.4))
		"shambler":
			_poly(r, [[-0.62, 0.55], [-0.52, 0.05], [-0.3, -0.3], [-0.05, -0.52],
				[0.25, -0.32], [0.5, 0.0], [0.6, 0.55]], pc)
			draw_circle(Vector2(-0.12, -0.1) * r, 0.06 * r, Color("cfe8a0"), true, -1.0, true)
			draw_circle(Vector2(0.14, -0.05) * r, 0.06 * r, Color("cfe8a0"), true, -1.0, true)
		"ghost":
			var g := pc
			g.a = 0.85
			_poly(r, [[-0.45, 0.15], [-0.42, -0.25], [-0.2, -0.5], [0.2, -0.5],
				[0.42, -0.25], [0.45, 0.2], [0.5, 0.6], [0.3, 0.42], [0.12, 0.62],
				[-0.12, 0.44], [-0.3, 0.64], [-0.48, 0.45]], g)
			draw_circle(Vector2(-0.14, -0.2) * r, 0.07 * r, dark, true, -1.0, true)
			draw_circle(Vector2(0.14, -0.2) * r, 0.07 * r, dark, true, -1.0, true)
		"knight":
			_poly(r, [[-0.6, 0.72], [-0.48, 0.3], [-0.2, 0.14], [0.2, 0.14],
				[0.48, 0.3], [0.6, 0.72]], pc.darkened(0.12))
			_poly(r, [[-0.07, -0.58], [0.07, -0.58], [0.16, -0.92], [-0.16, -0.92]], ring_color)
			draw_circle(Vector2(0, -0.3) * r, 0.36 * r, pc, true, -1.0, true)
			_poly(r, [[-0.36, -0.3], [0.36, -0.3], [0.36, 0.1], [-0.36, 0.1]], pc)
			_poly(r, [[-0.3, -0.24], [0.3, -0.24], [0.3, -0.13], [-0.3, -0.13]], dark)
		"cleric":
			_bust(r, pc)
			draw_arc(Vector2(0, -0.26) * r, 0.52 * r, PI * 1.08, PI * 1.92, 24,
				Color("e8d8a0"), 2.0, true)
		"bust_hood":
			_poly(r, [[-0.58, 0.72], [-0.5, 0.2], [-0.42, -0.45], [0.0, -0.72],
				[0.42, -0.45], [0.5, 0.2], [0.58, 0.72]], pc)
			draw_circle(Vector2(0, -0.18) * r, 0.26 * r, dark, true, -1.0, true)
		"bust_bun":
			_bust(r, pc)
			draw_circle(Vector2(0, -0.68) * r, 0.13 * r, pc, true, -1.0, true)
		"bust_cap":
			_bust(r, pc)
			_poly(r, [[-0.4, -0.45], [0, -0.7], [0.4, -0.45], [0.54, -0.36],
				[-0.54, -0.36]], pc.darkened(0.3))
		"bandit":
			_bust(r, pc)
			_poly(r, [[-0.36, -0.32], [0.36, -0.32], [0.3, -0.02], [-0.3, -0.02]], dark)
			draw_circle(Vector2(-0.13, -0.4) * r, 0.05 * r, dark, true, -1.0, true)
			draw_circle(Vector2(0.13, -0.4) * r, 0.05 * r, dark, true, -1.0, true)
		_:
			_bust(r, pc)

func _bust(r: float, pc: Color) -> void:
	_poly(r, [[-0.58, 0.72], [-0.46, 0.3], [-0.18, 0.12], [0.18, 0.12],
		[0.46, 0.3], [0.58, 0.72]], pc)
	draw_circle(Vector2(0, -0.26) * r, 0.34 * r, pc, true, -1.0, true)

func _skull(r: float, pc: Color, dark: Color) -> void:
	draw_circle(Vector2(0, -0.14) * r, 0.4 * r, pc, true, -1.0, true)
	_poly(r, [[-0.26, 0.14], [0.26, 0.14], [0.2, 0.52], [-0.2, 0.52]], pc)
	draw_circle(Vector2(-0.16, -0.16) * r, 0.1 * r, dark, true, -1.0, true)
	draw_circle(Vector2(0.16, -0.16) * r, 0.1 * r, dark, true, -1.0, true)
	_poly(r, [[0, -0.02], [-0.06, 0.12], [0.06, 0.12]], dark)
	for i in 3:
		draw_line(Vector2(-0.1 + 0.1 * i, 0.2) * r, Vector2(-0.1 + 0.1 * i, 0.46) * r, dark, 1.0, true)

func _wolf(r: float, pc: Color, dark: Color, alpha_wolf: bool) -> void:
	_poly(r, [[-0.66, 0.08], [-0.5, -0.05], [-0.3, -0.12], [-0.18, -0.4],
		[-0.08, -0.72], [0.1, -0.35], [0.28, -0.68], [0.38, -0.3], [0.52, -0.12],
		[0.56, 0.2], [0.44, 0.5], [0.0, 0.55], [-0.3, 0.4], [-0.5, 0.28]], pc)
	var eye := Color("e05a3a") if alpha_wolf else dark
	draw_circle(Vector2(-0.22, -0.14) * r, 0.07 * r, eye, true, -1.0, true)

func _spider(r: float, pc: Color) -> void:
	var leg := pc.darkened(0.1)
	for side in [-1, 1]:
		for i in 4:
			var y0 := -0.25 + i * 0.16
			var joint := Vector2(side * (0.42 + 0.04 * i), y0 - 0.18) * r
			var tip := Vector2(side * (0.7 - 0.04 * i), y0 + 0.14) * r
			draw_line(Vector2(side * 0.12, y0 + 0.05) * r, joint, leg, 1.6, true)
			draw_line(joint, tip, leg, 1.6, true)
	draw_circle(Vector2(0, 0.18) * r, 0.3 * r, pc, true, -1.0, true)
	draw_circle(Vector2(0, -0.24) * r, 0.2 * r, pc, true, -1.0, true)
	draw_circle(Vector2(-0.07, -0.3) * r, 0.045 * r, Color("e05a3a"), true, -1.0, true)
	draw_circle(Vector2(0.07, -0.3) * r, 0.045 * r, Color("e05a3a"), true, -1.0, true)

func _poly(r: float, pts: Array, c: Color) -> void:
	var out := PackedVector2Array()
	for p in pts:
		out.append(Vector2(p[0], p[1]) * r)
	draw_colored_polygon(out, c)
