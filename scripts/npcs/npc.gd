extends Area2D
## MODULE: NPCs
## PURPOSE: A data-driven NPC body in the world. Its DEFINITION (name, map,
##   position, dialogue id, faction, quest hooks, schedule placeholder) lives
##   in data/npcs/npcs.json. Interacting only ASKS for dialogue via EventBus -
##   this node holds zero conversation logic.
## SAFE TO EDIT: visuals (swap Label glyph for Sprite2D), idle wander,
##   schedule handling using def["schedule"].
## DANGEROUS: emitting anything other than dialogue_requested from interact().
## PUBLIC API: setup(npc_id), interact()
## FUTURE: schedules (def has a placeholder), pathfinding, portraits, barks.

const TILE := 32
var npc_id: String
var _def: Dictionary

func setup(id: String) -> void:
	npc_id = id
	_def = Db.get_npc(id)

func _ready() -> void:
	add_to_group("interactable")
	position = Vector2(_def["pos"][0] * TILE + TILE / 2.0, _def["pos"][1] * TILE + TILE / 2.0)
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 14.0
	shape.shape = circle
	add_child(shape)
	var token := TokenIcon.create(_def.get("icon", "bust"), npc_id,
		Color(_def.get("color", "7fa05a")), Color("c9c4b4"), 13.0)
	add_child(token)
	var name_lbl := Presentation.world_label(_def.get("name", npc_id), 11, Vector2(-30, -34))
	add_child(name_lbl)

func interact() -> void:
	EventBus.dialogue_requested.emit(_def.get("dialogue", ""), npc_id)
