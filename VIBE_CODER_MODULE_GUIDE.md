# Vibe Coder Module Guide
How to grow this game safely, one module at a time. Every script's header
tells you what's safe and what's dangerous in that file.

## Where to ADD things (usually data-only, no code!)
- **New NPC**: add an entry to `data/npcs/npcs.json`, add its id to the map's
  `"npcs"` list in `data/maps/<map>.json`, create `data/dialogue/<id>.json`.
- **New dialogue**: new file in `data/dialogue/` (format at top of
  `scripts/dialogue/dialogue_ui.gd`). New condition/event types: extend
  `_condition_met()` / `_apply_event()` there.
- **New quest**: add to `data/quests/quests.json` (kill / collect / event
  objectives), then start/turn it in from any dialogue via events. New
  objective types: `scripts/quests/quest_manager.gd` -> `_objective_done()`.
- **New monster**: add stat block to `data/monsters/monsters.json`, place it in
  a map's `"monsters"` list. New combat behaviours: read `traits` in
  `scripts/combat/combat_scene.gd` -> `_enemy_turn()`.
- **New item**: add to `data/items/items.json`. New consumable effects:
  `scripts/inventory/inventory.gd` -> `use_item()`.
- **New map**: new file in `data/maps/` + a portal from an existing map.
- **New class**: add to `data/classes/classes.json`; its ability needs a case
  in `combat_scene.gd` -> `_use_ability()`.

## Where to IMPROVE systems
- **Graphics**: `scripts/graphics/presentation.gd` (lighting/particles/shaders),
  `scripts/maps/map_builder.gd` (swap ColorRect tiles for a TileMapLayer +
  tileset - keep reading the same JSON grid), `scripts/player/player.gd` and
  `scripts/npcs/npc.gd` `_ready()` (swap ColorRects for Sprite2D/AnimatedSprite2D,
  drop art in `res://art/`).
- **Combat**: everything in `scripts/combat/combat_scene.gd` - add abilities,
  status effects, multi-enemy support. Keep the victory/defeat EventBus emits.
- **Character creation**: `scripts/ui/character_creation.gd` (point-buy,
  portraits, backgrounds) - it must still finish by calling `GameState.new_game()`.
- **Saving/loading**: `scripts/save/save_manager.gd`. Add fields inside each
  module's `export_state()/import_state()`; bump `VERSION` + add `_migrate()`.
- **Audio**: drop .ogg files in `res://audio/`, register in
  `scripts/audio/audio_manager.gd` TRACKS/SFX.
- **UI polish**: `scripts/ui/hud.gd`, `title_screen.gd`, `dialogue_ui.gd`
  `_build_ui()` functions - restyle freely, they only display state.

## DANGEROUS files (edit with care, or not at all)
- `scripts/core/event_bus.gd` - ADD signals freely; never rename/remove.
- Key names in `GameState.player`, `Db.*` getters, quest state strings
  ("inactive/active/ready/done"), dialogue JSON keys, the spawn_key/chest_key
  formats - saves and every module depend on these exact strings.
- `scripts/core/scene_router.gd` - only place scene changes may happen.
- `project.godot` autoload list and order.

## How to test nothing broke (2 minutes)
1. Run the game (F5). The Output panel must show
   `[Db] loaded: 3 classes, 3 monsters, 3 npcs, ...` with no red errors.
2. New Adventure -> pick each class once -> spawn in village.
3. Press **F1** (debug): +50 gold, give pelts, Fight: wolf (win), Fight: BOSS.
4. Talk to the Elder (accept quest), Borin (buy potion, turn in pelts),
   walk east portal -> Darkwood -> mine, open the chest, kill the Matron,
   return, turn in. Press **I** and **J** along the way.
5. Save from the inventory panel, quit, Continue - position, gold, quests
   and cleared monsters must all match.
If a data file is broken, the Output panel prints `[Db] Bad JSON in: ...` or
`[Dialogue] missing node: ...` - the game names the file for you.
