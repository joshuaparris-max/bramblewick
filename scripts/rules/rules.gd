extends Node
## MODULE: Rules (5e-inspired rules + dice)
## PURPOSE: The ONLY place dice are rolled and D&D maths lives.
##   Combat, dialogue and debug all call in here, so balance changes are one-file.
## SAFE TO EDIT: DCs, crit rules, proficiency curve, new roll helpers.
## DANGEROUS: changing return dictionary keys ("total","raw","ok"...) breaks callers.
## PUBLIC API:
##   roll(sides), roll_dice("2d6+3") -> int
##   d20(advantage:=0) -> {raw:int, second:int}   (advantage: 1 adv, -1 dis, 0 normal)
##   ability_mod(score) -> int
##   proficiency(level) -> int
##   skill_check(skill, dc, actor) -> {ok, raw, total, dc, text}
##   attack_roll(bonus, target_ac, advantage) -> {hit, crit, raw, total}
##   xp_threshold(level) -> int
## FUTURE: saving throws by ability, conditions, resistances, feats.

const SKILL_ABILITY := {
	"athletics": "STR", "stealth": "DEX", "acrobatics": "DEX",
	"investigation": "INT", "arcana": "INT", "religion": "INT",
	"insight": "WIS", "perception": "WIS", "survival": "WIS",
	"persuasion": "CHA", "intimidation": "CHA", "deception": "CHA",
}
const XP_THRESHOLDS := [0, 300, 900, 2700, 6500]

func roll(sides: int) -> int:
	return randi() % sides + 1

func roll_dice(notation: String) -> int:
	# Supports "NdS", "NdS+M", "NdS-M", or plain integers like "3".
	var s := notation.strip_edges().to_lower()
	if not "d" in s:
		return int(s)
	var bonus := 0
	var core := s
	if "+" in s:
		var parts := s.split("+"); core = parts[0]; bonus = int(parts[1])
	elif "-" in s.substr(1):
		var idx := s.rfind("-"); core = s.substr(0, idx); bonus = -int(s.substr(idx + 1))
	var nd := core.split("d")
	var n := maxi(1, int(nd[0])) if nd[0] != "" else 1
	var sides := int(nd[1])
	var total := bonus
	for i in n:
		total += roll(sides)
	return total

func d20(advantage: int = 0) -> Dictionary:
	var a := roll(20)
	var b := roll(20)
	var raw := a
	if advantage > 0: raw = maxi(a, b)
	elif advantage < 0: raw = mini(a, b)
	return {"raw": raw, "second": b}

func ability_mod(score: int) -> int:
	return floori((score - 10) / 2.0)

func proficiency(level: int) -> int:
	return 2 + int(maxi(0, level - 1) / 4)

func skill_check(skill: String, dc: int, actor: Dictionary) -> Dictionary:
	# actor = GameState.player (needs "stats", "level", "skill_profs")
	var ability: String = SKILL_ABILITY.get(skill, "WIS")
	var m := ability_mod(actor["stats"].get(ability, 10))
	if skill in actor.get("skill_profs", []):
		m += proficiency(actor.get("level", 1))
	var r := d20()
	var total: int = r["raw"] + m
	var ok: bool = (total >= dc) or r["raw"] == 20
	var text := "%s check: d20(%d) %+d = %d vs DC %d - %s" % [
		skill.capitalize(), r["raw"], m, total, dc, "success" if ok else "failure"]
	return {"ok": ok, "raw": r["raw"], "total": total, "dc": dc, "text": text}

func attack_roll(bonus: int, target_ac: int, advantage: int = 0) -> Dictionary:
	var r := d20(advantage)
	var crit: bool = r["raw"] == 20
	var total: int = r["raw"] + bonus
	var hit: bool = crit or (r["raw"] != 1 and total >= target_ac)
	return {"hit": hit, "crit": crit, "raw": r["raw"], "total": total}

func xp_threshold(level: int) -> int:
	return XP_THRESHOLDS[clampi(level, 0, XP_THRESHOLDS.size() - 1)]
