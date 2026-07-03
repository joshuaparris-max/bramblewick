# Shadow Over Bramblewick (Godot 4)

A modular, data-driven D&D-5e-flavoured RPG vertical slice.

## Run it
1. Install Godot 4.2 or newer (standard build).
2. Open Godot -> Import -> select this folder's `project.godot`.
3. Press F5 (Play).

## Share a browser build

Open the repository's **Actions** tab, choose **Publish playable web build**, and
click **Run workflow**. The resulting GitHub Pages URL is the permanent
playtest link. Publishing also runs automatically whenever `main` changes.

For itch.io, right-click `publish-web.ps1` and choose **Run with PowerShell**.
It creates `build/bramblewick-web.zip`, opens the itch.io upload page, and
selects the ZIP in Explorer. Godot's matching export templates must be installed.

## Controls
- Move: WASD / arrows / left stick / d-pad
- Interact: E / Space / gamepad A
- Inventory: I - Quest journal: J - Debug panel: F1
- Touch: on-screen controls appear automatically on touchscreens.

## Read next
- ARCHITECTURE.md - module map, data formats, build order
- VIBE_CODER_MODULE_GUIDE.md - where to add content safely
