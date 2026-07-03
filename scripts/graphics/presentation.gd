extends Node
class_name Presentation
## MODULE: Graphics/Presentation
## PURPOSE: Visual polish layer for exploration: map colour grading via
##   CanvasModulate, ambient flicker. Displays state; never changes rules.
## SAFE TO EDIT: everything - this module exists to be replaced with real art.
##   Add particles, lighting (PointLight2D on the player), shaders, weather.
## DANGEROUS: reading input or writing to GameState from here.
## PUBLIC API: static dress(map_data, parent), static world_label(text, font_size, pos)
## FUTURE: day/night cycle, screen-shake helper, transition fades, parallax.

# Must match the Camera2D zoom in player.gd - world text is rasterized this
# much larger and scaled down so it stays pixel-sharp under the zoom.
const WORLD_TEXT_OVERSAMPLE := 1.6

static func dress(map_data: Dictionary, parent: Node2D) -> void:
	var tint := CanvasModulate.new()
	tint.color = Color(map_data.get("tint", "ffffff"))
	parent.add_child(tint)

static func world_label(text: String, font_size: int, pos: Vector2) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", roundi(font_size * WORLD_TEXT_OVERSAMPLE))
	lbl.scale = Vector2.ONE / WORLD_TEXT_OVERSAMPLE
	lbl.position = pos
	return lbl
