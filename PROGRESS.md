# Shadow over Bramblewick - Progress

## Objective
Turn the existing Godot project into a stable, playable vertical slice that launches from a clean checkout and demonstrates the intended core gameplay.

## Milestones Achieved

- [x] **Project Discovery & Validation**: Analysed the state of `shadow-over-bramblewick-godot`, checked repository branch, and confirmed basic Godot 4.7 headless compatibility.
- [x] **Export Pipeline Definition**: Ensured that the project builds using Godot headless export (targeting `dist/windows/bramblewick.pck` to run as a portable build with the standard executable).
- [x] **Automated Data Integrity Test**: Created `tests/test_runner.gd` and `test_runner.tscn` to load the database programmatically and verify all quests, portals, npcs, items, monsters, classes, and save logic are intact. The test successfully passes without errors.
- [x] **Physical Playthrough Simulation**: Created `tests/test_playthrough.gd` which systematically walks through the game loop headlessly using Godot's scene tree. It verifies that:
  - Title screen loads
  - Character creation creates a hero
  - Exploration scene loads maps correctly (Village, portals)
  - Player can move
  - Dialogue opens and closes
  - The Silent Mine quest can be accepted, progressed, and completed
  - Combat functions properly with state management
  - Saving and loading persists data
- [x] **Player Clarity**: Updated `README.md` with explicit instructions on running the game, playing the game, and using developer keyboard shortcuts.
- [x] **Source Control Discipline**: Pushed all test artifacts and workflow improvements back to the `agent/windows/playable-vertical-slice` branch cleanly.

## Completion Status
The playable vertical slice is complete and thoroughly validated both in data integrity and gameplay flow logic.

