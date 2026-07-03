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
var _round := 1
var _poison_turns := 0
var _player_disadvantage := false
var _enemy_guard := false
var _enemy_skips := false

var _log: RichTextLabel
var _foe_lbl: Label
var _hp_lbl: Label
var _actions: VBoxContainer
var _foe_bar: ProgressBar
var _hero_bar: ProgressBar
var _foe_token: TokenIcon
var _hero_token: TokenIcon
var _arena: Control

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
	var advantage := -1 if _player_disadvantage else 0
	_player_disadvantage = false
	var target_ac := int(m["ac"]) + (2 if _enemy_guard else 0)
	_enemy_guard = false
	var r := Rules.attack_roll(GameState.attack_bonus(), target_ac, advantage)
	if r["hit"]:
		var dmg := Rules.roll_dice(GameState.damage_string())
		if r["crit"]:
			dmg += Rules.roll_dice(GameState.weapon().get("damage", "1d2"))
			_say("[color=#7fa05a]CRITICAL! d20(20) - %d damage![/color]" % dmg)
			AudioManager.play_sfx("crit")
		else:
			_say("[color=#7fa05a]d20(%d)%+d = %d vs AC %d - hit for %d.[/color]"
				% [r["raw"], GameState.attack_bonus(), r["total"], int(m["ac"]), dmg])
		m_hp -= dmg
		if not r["crit"]: AudioManager.play_sfx("hit")
		_impact(_foe_token, Color("c4553d"))
	else:
		AudioManager.play_sfx("miss")
		_say("[color=#c4553d]d20(%d)%+d = %d vs AC %d - miss.[/color]"
			% [r["raw"], GameState.attack_bonus(), r["total"], int(m["ac"])])
	_after_player()

func _use_ability(key: String) -> void:
	match key:
		"second_wind":
			_ability_used = true
			var h: int = Rules.roll_dice("1d10") + GameState.player["level"]
			GameState.change_hp(h)
			AudioManager.play_sfx("heal")
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
			AudioManager.play_sfx("heal")
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
	if _poison_turns > 0:
		var poison_damage := Rules.roll_dice("1d4")
		GameState.change_hp(-poison_damage)
		_poison_turns -= 1
		AudioManager.play_sfx("poison")
		_say("[color=#9aad68]Poison burns for %d damage.[/color]" % poison_damage)
		_impact(_hero_token, Color("9aad68"))
	if GameState.player["hp"] <= 0:
		_defeat()
		return
	if "slow" in m.get("traits", []) and _enemy_skips:
		_enemy_skips = false
		_say("%s drags its bulk into position." % m["name"])
		_finish_enemy_turn()
		return
	_enemy_skips = "slow" in m.get("traits", [])
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
		_impact(_hero_token, Color("c4553d"))
		_apply_enemy_trait()
	else:
		_say("%s misses: d20(%d) = %d vs your AC %d." % [m["name"], r["raw"], r["total"], GameState.player["ac"]])
	_finish_enemy_turn()

func _apply_enemy_trait() -> void:
	var traits: Array = m.get("traits", [])
	if "poison" in traits and _poison_turns == 0 and Rules.roll(20) >= 11:
		_poison_turns = 2
		_say("[color=#9aad68]Venom takes hold (2 rounds).[/color]")
	if "flicker" in traits:
		_player_disadvantage = true
		_say("[color=#9fe8e0]The wisp flickers away; your next attack has disadvantage.[/color]")
	if "armoured" in traits and Rules.roll(20) >= 12:
		_enemy_guard = true
		_say("[color=#8a94b8]The warden raises its guard (+2 AC next attack).[/color]")

func _finish_enemy_turn() -> void:
	_busy = false
	_round += 1
	_refresh()
	if GameState.player["hp"] <= 0:
		_defeat()

func _victory() -> void:
	_say("[color=#7fa05a]%s is defeated![/color]" % m["name"])
	AudioManager.play_sfx("victory")
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
	var conditions := ""
	if _enemy_guard: conditions += "  [Guarded]"
	_foe_lbl.text = "%s   AC %d%s" % [m["name"], int(m["ac"]), conditions]
	var p: Dictionary = GameState.player
	var slots_txt: String = ("   Slots %d/%d" % [p["slots"], p["slots_max"]]) if int(p["slots_max"]) > 0 else ""
	var status_txt := ("   Poisoned %d" % _poison_turns) if _poison_turns > 0 else ""
	_hp_lbl.text = "%s   AC %d%s%s   Round %d" % [p["name"], p["ac"], slots_txt, status_txt, _round]
	_foe_bar.max_value = int(m["hp"])
	_foe_bar.value = maxi(0, m_hp)
	_hero_bar.max_value = int(p["hp_max"])
	_hero_bar.value = maxi(0, int(p["hp"]))
	_build_actions()

func _impact(token: TokenIcon, color: Color) -> void:
	token.pulse()
	var old := _arena.modulate
	_arena.modulate = color.lightened(0.2)
	var tween := create_tween()
	tween.tween_property(_arena, "modulate", old, 0.22)

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
	bg.color = Color("0d0b0c")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	_arena = Control.new()
	_arena.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_arena)
	var mist := ColorRect.new()
	mist.color = Color(0.16, 0.09, 0.08, 0.38)
	mist.set_anchors_preset(Control.PRESET_FULL_RECT)
	_arena.add_child(mist)
	var v := VBoxContainer.new()
	v.set_anchors_preset(Control.PRESET_FULL_RECT)
	v.offset_left = 60.0; v.offset_right = -60.0
	v.offset_top = 30.0; v.offset_bottom = -30.0
	_arena.add_child(v)
	var title := Label.new()
	title.text = "⚔  ENCOUNTER"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color("e8b45a"))
	title.add_theme_font_size_override("font_size", 15)
	v.add_child(title)
	var portraits := HBoxContainer.new()
	portraits.alignment = BoxContainer.ALIGNMENT_CENTER
	portraits.custom_minimum_size.y = 116.0
	v.add_child(portraits)
	var hero_slot := Control.new()
	hero_slot.custom_minimum_size = Vector2(180, 110)
	portraits.add_child(hero_slot)
	var class_def := Db.get_class_def(GameState.player.get("class_id", ""))
	_hero_token = TokenIcon.create(class_def.get("icon", "knight"), "player_combat",
		Color("e8b45a"), Color("e8c878"), 38.0)
	_hero_token.position = Vector2(90, 54)
	hero_slot.add_child(_hero_token)
	var versus := Label.new()
	versus.text = "VS"
	versus.add_theme_font_size_override("font_size", 22)
	versus.add_theme_color_override("font_color", Color("8a7a62"))
	portraits.add_child(versus)
	var foe_slot := Control.new()
	foe_slot.custom_minimum_size = Vector2(180, 110)
	portraits.add_child(foe_slot)
	_foe_token = TokenIcon.create(m.get("icon", "flame"), m["id"], Color(m.get("color", "c4553d")),
		Color("e8b45a") if m.get("boss", false) else Color("8a6a4a"), 42.0)
	_foe_token.position = Vector2(90, 54)
	foe_slot.add_child(_foe_token)
	_foe_lbl = Label.new()
	_foe_lbl.add_theme_color_override("font_color", Color("c4553d"))
	_foe_lbl.add_theme_font_size_override("font_size", 22)
	v.add_child(_foe_lbl)
	_foe_bar = ProgressBar.new()
	_foe_bar.show_percentage = true
	_foe_bar.custom_minimum_size.y = 22.0
	v.add_child(_foe_bar)
	_hp_lbl = Label.new()
	_hp_lbl.add_theme_color_override("font_color", Color("7fa05a"))
	v.add_child(_hp_lbl)
	_hero_bar = ProgressBar.new()
	_hero_bar.show_percentage = true
	_hero_bar.custom_minimum_size.y = 22.0
	v.add_child(_hero_bar)
	_log = RichTextLabel.new()
	_log.bbcode_enabled = true
	_log.scroll_following = true
	_log.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(_log)
	_actions = VBoxContainer.new()
	v.add_child(_actions)
