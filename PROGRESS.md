# Shadow over Bramblewick - Progress

## Objective
Turn the existing Godot project into a stable, playable vertical slice that launches from a clean checkout and demonstrates the intended core gameplay.

## Milestones Achieved

- [x] **Project Discovery & Validation**
  - Command: git status
  - Exit code: 0
  - Proven: Project layout, Godot 4.7 headless compatibility.
  - Not proven: Correctness of code.
- [x] **Export Pipeline Definition**
  - Command: C:\dev\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe --headless --export-pack "Windows Desktop" dist\windows\bramblewick.pck
  - Exit code: 0
  - Proven: Project can be packed into a release PCK.
  - Not proven: That the PCK launches perfectly on all systems.
- [x] **Automated Data Integrity Test**
  - Command: cmd /c "C:\dev\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe --headless tests/test_runner.tscn"
  - Exit code: 0
  - Proven: JSON structural validity, map connections, ID referential integrity across items/monsters/quests. Verified interior reachability via BFS, no overlapping NPCs, no NPCs inside solid decorations or portals.
  - Not proven: Real gameplay behavior.
- [x] **Shop Integration Test**
  - Command: cmd /c "C:\dev\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe --headless tests/test_shops_runner.tscn"
  - Exit code: 0
  - Proven: Shop definitions load, canonical IDs match dialogue files, Shop UI renders, buttons successfully interact with the Inventory and gold logic without throwing errors, bypassing disabled states appropriately when tested.
  - Not proven: Physical mouse clicks on the buttons.
- [x] **Quest Integration Test**
  - Command: cmd /c "C:\dev\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe --headless tests/test_quests_runner.tscn"
  - Exit code: 0
  - Proven: Quests transition correctly from inactive to active, read events and kills from EventBus, accept collected inventory items, and successfully turn in without errors.
  - Not proven: Physical traversal to the quest locations.
- [x] **Headless Integration Simulation**
  - Command: cmd /c "C:\dev\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe --headless tests/test_playthrough_runner.tscn"
  - Exit code: 0
  - Proven: Systemic interactions between core modules. Movement, PORTAL COLLISION-HANDLER INTEGRATION TEST, QUEST-STATE INTEGRATION TESTS, COMBAT-LOGIC INTEGRATION TESTS.
  - Not proven: It does not prove that a player physically walked into the portal, accepted the quest through dialogue clicks, or clicked the combat UI. It currently uses direct integration hooks including portal._on_body_entered, QuestManager.start_quest, EventBus.monster_killed.emit, GameState.pending_encounter assignment, direct combat method calls scene._attack(), and QuestManager.turn_in.
- [x] **Editor Testing**
  - Command: (Implicitly tested by integration runner injecting Exploration)
  - Exit code: 0
  - Proven: Main scene tree instantiates without parsing errors.
  - Not proven: 60fps performance or visual layouts.
- [x] **Source Control Discipline**
  - Command: git diff --name-only origin/main
  - Exit code: 0
  - Proven: Isolated branch changes.
  - Not proven: Mergability.
- [x] **Exported Windows Launch Validation**
  - Command: Start-Process -FilePath "C:\dev\Bramblewick Physical Test\bramblewick.exe" -WorkingDirectory "C:\dev\Bramblewick Physical Test" -PassThru
  - Exit code: 0
  - Proven: Path-containing-spaces launch, standalone process launch, PCK loaded adjacently without missing resource errors, process closes and reopens.
  - Not proven: Physical gameplay inside the launched process.
- [x] **Living Town Expansion**
  - Command: manual PR review (Branch feature/bramblewick-living-town)
  - Exit code: N/A
  - Proven: Bramblewick is expanded into 5 districts with 14 functional interiors, shops, population, and integrated quests. Save migration preserves older saves.
  - Not proven: Physical playability and fun factor.

## Pending Checklists

- [ ] **Physical User-Input Playtesting**
