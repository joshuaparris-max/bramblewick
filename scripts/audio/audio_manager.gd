extends Node
## MODULE: Audio
## PURPOSE: One place for music/ambience/SFX. Ships silent-safe: if an audio
##   file is missing it just skips, so the game never crashes over sound.
## SAFE TO EDIT: drop .ogg files into res://audio/ and register them in TRACKS/
##   SFX below; add crossfading.
## DANGEROUS: none really - this module may not affect game rules, ever.
## PUBLIC API: play_music(id), stop_music(), play_sfx(id)
## FUTURE: volume settings menu, positional audio, footsteps by tile type,
##   combat stingers, voice barks.

const TRACKS := {
	# "village": "res://audio/village_theme.ogg",
	# "combat": "res://audio/combat_theme.ogg",
}
const SFX := {
	# "hit": "res://audio/hit.ogg",
	# "ui": "res://audio/ui_click.ogg",
}

var _music := AudioStreamPlayer.new()
var _sfx := AudioStreamPlayer.new()

func _ready() -> void:
	add_child(_music)
	add_child(_sfx)

func play_music(id: String) -> void:
	if not TRACKS.has(id) or not ResourceLoader.exists(TRACKS[id]):
		return
	_music.stream = load(TRACKS[id])
	_music.play()

func stop_music() -> void:
	_music.stop()

func play_sfx(id: String) -> void:
	if not SFX.has(id) or not ResourceLoader.exists(SFX[id]):
		return
	_sfx.stream = load(SFX[id])
	_sfx.play()
