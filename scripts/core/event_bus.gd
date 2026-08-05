extends Node
## MODULE: EventBus (core)
## PURPOSE: The single message board every module talks through.
##   Modules NEVER call deep into each other; they emit/listen here.
## SAFE TO EDIT: add new signals (append to the list, keep names snake_case).
## DANGEROUS: renaming/removing existing signals breaks every listener.
## PUBLIC API: the signals below. Emit with EventBus.signal_name.emit(...).
## FUTURE: party events, weather events, faction war events, achievements.

# --- player / state ---
signal state_changed                    # anything HUD-visible changed (hp, gold, xp...)
signal player_leveled(new_level: int)
signal player_died

# --- exploration ---
signal map_loaded(map_id: String)
signal portal_used(to_map: String)
signal chest_opened(chest_key: String)

# --- dialogue ---
signal dialogue_requested(dialogue_id: String, npc_id: String)
signal shop_requested(shop_id: String)
signal dialogue_started(npc_id: String)
signal dialogue_finished(npc_id: String)
signal dialogue_event(event_name: String)      # generic hook quests can listen to
signal reputation_changed(faction: String, amount: int)

# --- quests ---
signal quest_started(quest_id: String)
signal quest_updated(quest_id: String)
signal quest_ready(quest_id: String)            # objectives done, needs turn-in
signal quest_completed(quest_id: String)

# --- inventory ---
signal item_gained(item_id: String, count: int)
signal item_lost(item_id: String, count: int)
signal gold_changed(new_amount: int)
signal equipment_changed

# --- combat ---
signal encounter_requested(monster_id: String, spawn_key: String)
signal combat_started(monster_id: String)
signal monster_killed(monster_id: String)
signal combat_ended(victory: bool, spawn_key: String)

# --- system ---
signal game_saved
signal game_loaded
signal toast(message: String)                   # small HUD notifications

