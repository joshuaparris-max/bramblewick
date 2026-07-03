extends Node
## MODULE: Main (boot)
## PURPOSE: Entry scene. Seeds RNG and routes to the title screen.
## SAFE TO EDIT: startup checks, splash logic.
## DANGEROUS: putting game logic here - it belongs in modules.

func _ready() -> void:
	randomize()
	SceneRouter.goto("title")
