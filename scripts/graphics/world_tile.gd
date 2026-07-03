class_name WorldTile
extends Node2D
## Procedural terrain tile. Deterministic detail keeps maps cohesive without
## external textures and can later be replaced by a TileMap atlas.

const SIZE := 32.0
var kind := "."
var base := Color("1d2a19")
var seed_value := 0

static func create(tile_kind: String, color: Color, grid_pos: Vector2i) -> WorldTile:
	var tile := WorldTile.new()
	tile.kind = tile_kind
	tile.base = color
	tile.seed_value = grid_pos.x * 92821 + grid_pos.y * 68917
	tile.position = Vector2(grid_pos) * SIZE
	return tile

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(SIZE, SIZE)), base)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	match kind:
		"#":
			draw_circle(Vector2(16, 18), 15, base.lightened(0.08))
			draw_circle(Vector2(10, 12), 9, base.lightened(0.15))
			draw_circle(Vector2(23, 10), 8, base.darkened(0.12))
			draw_line(Vector2(16, 24), Vector2(16, 32), Color("3a2618"), 3)
		".":
			for i in 5:
				var p := Vector2(rng.randf_range(3, 29), rng.randf_range(5, 30))
				draw_line(p, p + Vector2(rng.randf_range(-2, 2), -rng.randf_range(2, 5)),
					base.lightened(rng.randf_range(0.08, 0.2)), 1)
		",":
			for i in 7:
				var p := Vector2(rng.randf_range(2, 30), rng.randf_range(2, 30))
				draw_circle(p, rng.randf_range(0.6, 1.5), base.lightened(rng.randf_range(0.05, 0.16)))
		"~":
			for y in [8.0, 17.0, 26.0]:
				var offset := rng.randf_range(-4, 3)
				draw_arc(Vector2(16 + offset, y), 9, 0.15, PI - 0.15, 12, base.lightened(0.25), 1)
		"^":
			var rock := PackedVector2Array([Vector2(3, 28), Vector2(10, 8), Vector2(18, 3), Vector2(29, 28)])
			draw_colored_polygon(rock, base.lightened(0.12))
			draw_line(Vector2(18, 3), Vector2(15, 27), base.darkened(0.2), 1)
		"=":
			for y in [5.0, 16.0, 27.0]:
				draw_line(Vector2(0, y), Vector2(32, y + rng.randf_range(-1, 1)), base.lightened(0.08), 1)
		"W":
			draw_rect(Rect2(1, 2, 30, 28), base.lightened(0.08))
			for y in [10.0, 20.0]: draw_line(Vector2(1, y), Vector2(31, y), base.darkened(0.18), 1)
			draw_line(Vector2(11, 2), Vector2(11, 10), base.darkened(0.18), 1)
			draw_line(Vector2(22, 10), Vector2(22, 20), base.darkened(0.18), 1)
	draw_line(Vector2(0, 31), Vector2(32, 31), Color(0, 0, 0, 0.12), 1)
