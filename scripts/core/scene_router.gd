extends Node
## MODULE: SceneRouter (core)
## PURPOSE: The only module that changes scenes. Everything else calls
##   SceneRouter.goto("title"|"create"|"explore"|"combat").
## SAFE TO EDIT: add new screens to SCREENS.
## DANGEROUS: calling get_tree().change_scene_* anywhere else in the project.
## PUBLIC API: goto(screen_id), start_encounter(monster_id, spawn_key)
## FUTURE: transitions/fades, loading screens, scene preloading.

const SCREENS := {
	"title": "res://scenes/ui/title_screen.tscn",
	"create": "res://scenes/character_creation/character_creation.tscn",
	"explore": "res://scenes/maps/exploration.tscn",
	"combat": "res://scenes/combat/combat.tscn",
}

func _ready() -> void:
	EventBus.encounter_requested.connect(start_encounter)

func goto(screen_id: String) -> void:
	assert(SCREENS.has(screen_id), "Unknown screen: " + screen_id)
	get_tree().call_deferred("change_scene_to_file", SCREENS[screen_id])

func start_encounter(monster_id: String, spawn_key: String) -> void:
	GameState.pending_encounter = {"monster_id": monster_id, "spawn_key": spawn_key}
	goto("combat")
