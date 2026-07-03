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

const SYNTH_SFX := {
	"hit": [92.0, 0.09, 0.42],
	"crit": [180.0, 0.18, 0.55],
	"miss": [55.0, 0.07, 0.18],
	"heal": [440.0, 0.22, 0.24],
	"poison": [125.0, 0.18, 0.22],
	"victory": [660.0, 0.3, 0.28],
	"ui": [330.0, 0.04, 0.14],
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
	if SFX.has(id) and ResourceLoader.exists(SFX[id]):
		_sfx.stream = load(SFX[id])
	elif SYNTH_SFX.has(id):
		_sfx.stream = _make_tone(SYNTH_SFX[id])
	else:
		return
	_sfx.play()

func _make_tone(spec: Array) -> AudioStreamWAV:
	var frequency := float(spec[0])
	var duration := float(spec[1])
	var volume := float(spec[2])
	var mix_rate := 22050
	var frames := int(duration * mix_rate)
	var bytes := PackedByteArray()
	bytes.resize(frames * 2)
	for i in frames:
		var t := float(i) / mix_rate
		var envelope := pow(1.0 - float(i) / frames, 2.0)
		var sample := sin(TAU * frequency * t) + 0.35 * sin(TAU * frequency * 1.5 * t)
		bytes.encode_s16(i * 2, int(clampf(sample * envelope * volume, -1.0, 1.0) * 32767.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = mix_rate
	wav.stereo = false
	wav.data = bytes
	return wav
