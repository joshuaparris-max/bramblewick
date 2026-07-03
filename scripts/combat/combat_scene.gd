extends Control
## MODULE: Combat
## PURPOSE: Turn-based d20 combat: initiative, attacks, class abilities,
##   items, fleeing, enemy turns, victory/defeat, rewards, combat log.
##   Reads the monster stat block from Db; rolls through Rules; reports
##   results via EventBus (monster_killed, combat_ended). It never touches
##   quest code - QuestManager hears monster_killed on its own.
## SAFE TO EDIT: add class abilities in _build_actions()/_use_ability(),
##   add monster traits in _enemy_turn() (read m["traits"]), restyle _build_ui().
## DANGEROUS: skipping the EventBus signals on victory - quests and map
##   clearing depend on them.
## PUBLIC API: reads GameState.pending_encounter {"monster_id","spawn_key"}.
## FUTURE: multi-enemy encounters, positioning grid, status effects,
##   animations via a CombatPresenter, victory screen with loot cards.

var m: Dictionary               # monster stat block (runtime copy)
var m_hp: int
var spawn_key: String
var _ability_used := false
var _busy := false

var _log: RichTextLabel
var _foe_lbl: Label
var _hp_lbl: Label
var _actions: VBoxContainer

func _ready() -> void:
	var enc: Dictionary = GameState.pending_encounter
	m = Db.get_monster(enc.get("monster_id", "")).duplicate(true)
	spawn_key = enc.get("spawn_key", "")
	m_hp = int(m.get("hp", 1))
	_build_ui()
	EventBus.combat_started.emit(m["id"])
	_say("[color=#8a7a62]%s[/color]" % m.get("flavor", "It attacks!"))
	var p_init: int = Rules.roll(20) + Rules.ability_mod(GameState.player["stats"]["DEX"])
	var m_init: int = Rules.roll(20) + int(m.get("initiative_bonus", 2))
	_say("Initiative - you %d, %s %d." % [p_init, m["name"], m_init])
	if m_init > p_init:
		_enemy_turn()
	else:
		_refresh()

# ---------- player actions ----------
func _attack() -> void:
	var r := Rules.attack_roll(GameState.attack_bonus(), int(m["ac"]))
	if r["hit"]:
		var dmg := Rules.roll_dice(GameState.damage_string())
		if r["crit"]:
			dmg += Rules.roll_dice(GameState.weapon().get("damage", "1d2"))
			_say("[color=#7fa05a]CRITICAL! d20(20) - %d damage![/color]" % dmg)
		else:
			_say("[color=#7fa05a]d20(%d)%+d = %d vs AC %d - hit for %d.[/color]"
				% [r["raw"], GameState.attack_bonus(), r["total"], int(m["ac"]), dmg])
		m_hp -= dmg
	else:
		_say("[color=#c4553d]d20(%d)%+d = %d vs AC %d - miss.[/color]"
			% [r["raw"], GameState.attack_bonus(), r["total"], int(m["ac"])])
	_after_player()

func _use_ability(key: String) -> void:
	match key:
		"second_wind":
			_ability_used = true
			var h: int = Rules.roll_dice("1d10") + GameState.player["level"]
			GameState.change_hp(h)
			_say("[color=#7fa05a]Second Wind - +%d HP.[/color]" % h)
		"sneak_attack":
			_ability_used = true
			var r := Rules.attack_roll(GameState.attack_bonus(), int(m["ac"]), 1)
			if r["hit"]:
				var dmg := Rules.roll_dice(GameState.damage_string()) + Rules.roll_dice("1d6")
				m_hp -= dmg
				_say("[color=#6f8fc4]Sneak attack (advantage) - %d damage![/color]" % dmg)
			else:
				_say("[color=#c4553d]Even with advantage... a miss.[/color]")
		"cure_wounds":
			if GameState.player["slots"] <= 0: return
			GameState.player["slots"] -= 1
			var h2: int = Rules.roll_dice("1d8+3")
			GameState.change_hp(h2)
			_say("[color=#7fa05a]Cure Wounds - +%d HP.[/color]" % h2)
	_after_player()

func _use_potion() -> void:
	if Inventory.use_item("potion_healing"):
		_say("[color=#7fa05a]You drink a healing potion.[/color]")
		_after_player()

func _flee() -> void:
	if m.get("boss", false):
		_say("[color=#c4553d]There is no fleeing this.[/color]")
		_after_player()
		return
	if Rules.roll(20) + Rules.ability_mod(GameState.player["stats"]["DEX"]) >= 11:
		_say("You break away!")
		EventBus.combat_ended.emit(false, "")
		SceneRouter.goto("explore")
	else:
		_say("[color=#c4553d]You stumble - no escape this round.[/color]")
		_after_player()

# ---------- turn flow ----------
func _after_player() -> void:
	_refresh()
	if m_hp <= 0:
		_victory()
	else:
		_enemy_turn()

func _enemy_turn() -> void:
	_busy = true
	_refresh()
	await get_tree().create_timer(0.6).timeout
	var r := Rules.attack_roll(int(m.get("attack_bonus", 3)), int(GameState.player["ac"]))
	if r["hit"]:
		var dmg := Rules.roll_dice(m.get("damage", "1d6"))
		if r["crit"]:
			dmg += Rules.roll_dice(m.get("damage", "1d6"))
			_say("[color=#c4553d]%s CRITS for %d damage![/color]" % [m["name"], dmg])
		else:
			_say("[color=#c4553d]%s hits: d20(%d) = %d vs your AC %d - %d damage.[/color]"
				% [m["name"], r["raw"], r["total"], GameState.player["ac"], dmg])
		GameState.change_hp(-dmg)
	else:
		_say("%s misses: d20(%d) = %d vs your AC %d." % [m["name"], r["raw"], r["total"], GameState.player["ac"]])
	_busy = false
	_refresh()
	if GameState.player["hp"] <= 0:
		_defeat()

func _victory() -> void:
	_say("[color=#7fa05a]%s is defeated![/color]" % m["name"])
	EventBus.monster_killed.emit(m["id"])
	GameState.add_xp(int(m.get("xp", 0)))
	if m.has("gold"):
		var g := Rules.roll_dice(str(m["gold"]))
		Inventory.add_gold(g)
	for loot in m.get("loot", []):
		if randf() <= float(loot.get("chance", 1.0)):
			Inventory.add(loot["item"], 1)
			EventBus.toast.emit("Loot: " + Db.get_item(loot["item"]).get("name", loot["item"]))
	if spawn_key != "":
		GameState.mark_spawn_cleared(spawn_key)
	EventBus.combat_ended.emit(true, spawn_key)
	await get_tree().create_timer(1.1).timeout
	SceneRouter.goto("explore")

func _defeat() -> void:
	_say("[color=#c4553d]Darkness takes you...[/color]")
	EventBus.combat_ended.emit(false, spawn_key)
	await get_tree().create_timer(1.4).timeout
	GameState.set_flag("player_defeated")
	SceneRouter.goto("title")

# ---------- UI ----------
func _refresh() -> void:
	_foe_lbl.text = "%s   HP %d/%d   AC %d" % [m["name"], maxi(0, m_hp), int(m["hp"]), int(m["ac"])]
	var p: Dictionary = GameState.player
	var slots_txt: String = ("   Slots %d/%d" % [p["slots"], p["slots_max"]]) if int(p["slots_max"]) > 0 else ""
	_hp_lbl.text = "%s   HP %d/%d   AC %d%s" % [p["name"], p["hp"], p["hp_max"], p["ac"], slots_txt]
	_build_actions()

func _build_actions() -> void:
	for child in _actions.get_children():
		child.queue_free()
	if _busy: return
	_mk_action("Attack - %s (%s)" % [GameState.weapon().get("name", "?"), GameState.damage_string()], _attack)
	for ab in GameState.player.get("abilities", []):
		var disabled: bool = (_ability_used and ab != "cure_wounds") \
			or (ab == "cure_wounds" and GameState.player["slots"] <= 0)
		_mk_action(ab.capitalize().replace("_", " "), _use_ability.bind(ab), disabled)
	_mk_action("Potion (%d)" % Inventory.count("potion_healing"), _use_potion,
		Inventory.count("potion_healing") <= 0)
	_mk_action("Flee", _flee)

func _mk_action(label: String, fn: Callable, disabled: bool = false) -> void:
	var b := Button.new()
	b.text = label
	b.disabled = disabled
	b.pressed.connect(fn)
	_actions.add_child(b)

func _say(bbcode: String) -> void:
	_log.append_text(bbcode + "\n")

func _build_ui() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	size = get_viewport_rect().size
	get_viewport().size_changed.connect(func(): size = get_viewport_rect().size)
	var bg := ColorRect.new()
	bg.color = Color("14100e")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var v := VBoxContainer.new()
	v.set_anchors_preset(Control.PRESET_FULL_RECT)
	v.offset_left = 60.0; v.offset_right = -60.0
	v.offset_top = 30.0; v.offset_bottom = -30.0
	add_child(v)
	_foe_lbl = Label.new()
	_foe_lbl.add_theme_color_override("font_color", Color("c4553d"))
	_foe_lbl.add_theme_font_size_override("font_size", 22)
	v.add_child(_foe_lbl)
	_hp_lbl = Label.new()
	_hp_lbl.add_theme_color_override("font_color", Color("7fa05a"))
	v.add_child(_hp_lbl)
	_log = RichTextLabel.new()
	_log.bbcode_enabled = true
	_log.scroll_following = true
	_log.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(_log)
	_actions = VBoxContainer.new()
	v.add_child(_actions)
