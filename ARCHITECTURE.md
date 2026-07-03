# Architecture - Shadow Over Bramblewick

## 1. The big picture
All game logic lives in **autoload singletons** (loaded in `project.godot`) plus **data files**.
Modules communicate ONLY through:
1. **EventBus signals** (`scripts/core/event_bus.gd`) - fire-and-forget notifications, or
2. **Small public APIs** documented in each script's header.

Scene files (.tscn) are deliberately minimal shells (one root node + script); each
script builds its own UI/nodes in `_ready()`. This keeps scenes uncorruptible and
lets any module be rewritten without touching the others.

Autoload order (matters - later ones may call earlier ones):
EventBus -> Db -> Rules -> GameState -> Inventory -> QuestManager -> SaveManager
-> AudioManager -> InputBootstrap -> SceneRouter

## 2. Folder structure
- `scenes/` - thin scene shells per screen (main, title, creation, exploration, combat, dialogue, HUD, touch, debug, player)
- `scripts/<module>/` - one folder per module (core, rules, player, maps, npcs, monsters, dialogue, quests, inventory, combat, save, input, ui, graphics, audio, debug)
- `data/<content type>/` - ALL content as JSON (classes, items, monsters, npcs, quests, dialogue, maps)
- `art/`, `audio/`, `resources/` - drop real assets here later
- `tests_or_debug/` - room for test scripts

## 3. Module map (who talks to whom)
- **EventBus** <- everyone emits/listens here
- **Db** - loads data/, read by everyone; writes nothing
- **Rules** - pure dice/5e maths; called by Combat, Dialogue, GameState, Debug
- **GameState** - owns player/flags/reputation/position/cleared spawns
- **Inventory** - owns items/equipment/gold
- **QuestManager** - owns quest states; LISTENS to monster_killed / item_gained / dialogue_event (combat and dialogue never edit quests directly)
- **SceneRouter** - the only module allowed to change scenes
- **SaveManager** - only calls each module's export_state()/import_state()
- **Player controller** - movement + "interact with nearest interactable" only
- **MapBuilder/Exploration** - build world from map JSON; portals/chests/NPCs/monster spawns are small self-contained nodes
- **Dialogue UI** - runs trees, applies typed events via public APIs
- **Combat** - fights one monster stat block, reports via EventBus
- **HUD/UI** - displays state, mutates nothing directly
- **Presentation / Audio** - polish only; forbidden from changing rules
- **Debug panel** - F1; pokes every module's public API for testing

## 4. Responsibilities
See the header comment block at the top of every script:
Purpose / Safe to edit / Dangerous / Public API / Future improvements.

## 5. Data formats (the exact shapes the code reads)
**Class** (`data/classes/classes.json`, array):
`{id, name, blurb, armour_note, stats{STR..CHA}, base_hp, hit_die, skill_profs[], abilities[], slots?, starting_equipment{slot:item_id}, starting_items{item_id:count}, gold, start_pos[x,y]}`

**Item** (`data/items/items.json`, array):
weapon `{id,name,type:"weapon",slot:"weapon",damage:"1d8",stat:"STR",bonus,value}`;
armour `{...type:"armour",slot:"armour"|"shield",ac,dex_cap,max_dex,value}`;
consumable `{...type:"consumable",effect:"heal",amount:"2d4+2"}`;
quest item `{...type:"quest"}`

**Monster** (`data/monsters/monsters.json`, array):
`{id,name,glyph,color,hp,ac,attack_bonus,damage:"2d4",initiative_bonus,xp,gold:"1d4",loot:[{item,chance}],traits[],behaviour,flavor,boss?}`

**NPC** (`data/npcs/npcs.json`, array):
`{id,name,map,pos[x,y],dialogue,faction,schedule,color,quest_hooks[]}`

**Dialogue** (`data/dialogue/<id>.json`, one file per tree):
`{id,start,nodes:{key:{text (string or list for variety), choices:[{label, next|null, condition?, check?{skill,dc} + ok/fail, events?[]}]}}}`
Conditions: flag / not_flag / has_item / gold_at_least / quest_state{id,is}.
Events: start_quest, turn_in_quest, set_flag, give_item, take_item, give_gold, take_gold, buy{item,cost}, heal_full, quest_event, reputation.

**Quest** (`data/quests/quests.json`, array):
`{id,name,giver,turn_in,desc,objectives:[{id,type:"kill"|"collect"|"event",monster?/item?/event?,count,desc}],rewards{gold,xp,items{}}}`

**Map** (`data/maps/<id>.json`):
`{id,name,tint,grid:[ASCII rows],portals:[{pos,to_map,to_pos,label,requires_flag?}],chests:[{pos,items{},gold?}],npcs:[ids],monsters:[{id,pos}]}`
Tiles: `#` tree/wall, `.` grass, `,` path, `~` water, `^` rock, `=` mine floor, `W` mine wall (solid: # ~ ^ W).

## 6. Vertical slice (what's playable now)
Title -> character creation (3 classes) -> Bramblewick village (Elder Maren: main quest with Insight check; Borin: shop, haggling, pelt quest) -> the Darkwood (3 wolves, Wren the hermit: lore/heal/Persuasion hint) -> Old Bramble Mine (skeletons, chest, boss: The Pale Matron) -> turn-in, rewards, level-ups; save/load throughout; keyboard/controller/touch input.

## 7. Safest build order (how it was built; how to extend)
1. EventBus + Db + Rules (no dependencies)
2. GameState + Inventory + QuestManager (state layer)
3. SaveManager + SceneRouter + InputBootstrap (services)
4. Player + MapBuilder + world nodes (portal/chest/NPC/monster spawn)
5. Dialogue, then Combat (consumers of everything above)
6. UI (title/creation/HUD), touch, debug panel
7. Content last: data files only.
When adding features, follow the same order: data format -> owning module -> events -> UI.
