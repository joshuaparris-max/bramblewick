# Shadow Over Bramblewick (Godot 4)

A modular, data-driven D&D-5e-flavoured RPG vertical slice.

## Vertical Slice Objective
The current vertical slice provides a complete gameplay loop. Your goal is to explore Bramblewick, speak to the Elder to accept "The Silent Mine" quest, and venture into the Old Bramble Mine to defeat the Pale Matron (Spider Boss).

## Run it in the Editor
1. Install **Godot 4.7** (standard build).
2. Open Godot -> Import -> select this folder's `project.godot`.
3. Press F5 (Play).

## Run the Windows Package
1. Navigate to `dist/windows/`
2. Run `bramblewick.exe`
(Note: It automatically loads the adjacent `bramblewick.pck` game data).

## Controls
- **Move**: WASD / arrows / left stick / d-pad
- **Interact / Advance Dialogue**: E / Space / gamepad A
- **Back / Cancel Menu**: Escape / gamepad B
- **Inventory**: I
- **Quest journal**: J
- **Debug panel**: F1
- **Touch**: on-screen controls appear automatically on touchscreens.

## Tests & Exporting
To verify integrity via the headless test suite, run:
`Godot_v4.7-stable_win64_console.exe --headless tests/test_runner.tscn`

To verify the playable vertical slice logic, run the playthrough test:
`Godot_v4.7-stable_win64_console.exe --headless tests/test_playthrough.tscn`

To build the Windows PCK fallback export, run:
`Godot_v4.7-stable_win64_console.exe --headless --export-pack "Windows Desktop" dist\windows\bramblewick.pck`
(Then copy your Godot 4.7 executable to `dist\windows\bramblewick.exe` to serve as the launcher).

## Read next
- ARCHITECTURE.md - module map, data formats, build order
- VIBE_CODER_MODULE_GUIDE.md - where to add content safely

