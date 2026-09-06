# Shadow Over Bramblewick - Development Roadmap

This roadmap turns the current vertical slice into a stronger playable RPG. Work should be delivered in milestones that improve the player-facing experience while keeping the data-driven architecture intact.

## Next Milestone: Village to Mine

Make the opening ten minutes feel intentional and easy to understand.

- Add a short playable tutorial for movement, interaction, combat, and inventory.
- [x] Add a clear interaction prompt when the player is close enough to an NPC, chest, or other interactable.
- Give the opening a strong mystery or choice before the player accepts the mine quest.
- Improve the village, Darkwood, and mine with distinct landmarks and visual identities.
- Add one polished combat encounter with readable enemy intent, hit feedback, sound, and a satisfying victory result.
- Verify the full route with physical keyboard and mouse input, including dialogue choices and portal traversal.

## Player Feedback

- Expand the HUD to show health, relevant resources, the active objective, and important status effects.
- Show toast or animation feedback when quests update, items are gained, gold changes, or reputation changes.
- Make locked portals explain their requirements in-world and in the quest journal.
- Add a readable quest journal with objectives, discovered locations, and completed quests.
- Replace debug-only save/load access with a player-facing save and load flow.

## Combat and Character Depth

- Add a small set of class abilities, defend, usable items, and meaningful resource decisions.
- Give enemies distinct behaviors, strengths, weaknesses, and encounter roles.
- Add positioning or environmental decisions where the map supports them.
- Add status effects and clear treatment or recovery rules.
- Surface damage, critical hits, misses, turn changes, and enemy intent through animation and UI.

## Exploration and World

- Add secrets, optional encounters, environmental puzzles, treasure, and shortcuts to existing maps.
- Add more landmarks so each map is easy to navigate without feeling like a grid of anonymous tiles.
- Add a minimap or world map when the number of connected locations makes it useful.
- Add optional NPC conversations and side quests that respond to the player's choices.

## Choice and Consequence

- Let dialogue choices affect reputation, prices, available quests, NPC reactions, and later outcomes.
- Give failed skill checks useful consequences or alternate information instead of treating failure as a dead end.
- Add a small number of authored quest outcomes rather than multiplying branches without follow-through.

## Presentation and Accessibility

- Replace placeholder token graphics with a consistent pixel-art sprite language.
- Add ambient audio, footsteps, combat sounds, music transitions, lighting, particles, and restrained screen shake.
- Add portraits and a typewriter effect to dialogue, with a text-speed option.
- Add settings for volume, fullscreen/windowed mode, controls, and text speed.
- Verify readable text, stable layouts, and usable controls at the target desktop and touch resolutions.

## Reliability and Release Quality

- Extend automated coverage from direct integration hooks to physical-style input flows where practical.
- Keep the data integrity test covering IDs, map connections, dialogue references, quests, items, and monsters.
- Run the complete manual playtest checklist for every release candidate.
- Validate clean-checkout launch, save/load, export packaging, and graceful shutdown on Windows.
- Record known gaps in `PROGRESS.md` instead of treating integration tests as proof of visual or physical playability.

## Suggested Delivery Order

1. Village-to-mine tutorial, prompts, HUD feedback, and physical-input playtest.
2. Combat abilities, enemy behaviors, item use, and encounter presentation.
3. Save/load UI, settings, quest journal, and accessibility polish.
4. Exploration secrets, optional quests, and meaningful choice consequences.
5. Sprite, audio, lighting, particles, and release-quality presentation pass.