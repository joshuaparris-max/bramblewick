# Bramblewick Town Manual Playtest

The living town expansion is ready for physical verification.
An exported build is available in: `C:\dev\Bramblewick Town Test\bramblewick.exe` (or launch via Godot with the `.pck`).

## Playtest Route

To verify all new components rapidly, follow this route:

1. **Market Square (Spawn)**:
   - Walk around to see ambient population (Shopper, Merchant, Child) wandering within bounds.
   - Speak to **Kael** inside the General Store to see the Shop UI and start **The Lost Delivery**.
   - Note the directional signs at major exits.

2. **Riverside (South)**:
   - Follow the sign south to Riverside.
   - Enter the **Warehouse** (southwest).
   - Click the chest to obtain `kael_package`.
   - Enter the **Mill** (northeast).
   - Speak to **Hobb** to accept **Trouble at the Mill**.
   - Defeat the 3 spiders inside the Mill. Turn in the quest to Hobb.

3. **Craftsmen's Row (West of Market)**:
   - Return north to Market Square, then go West.
   - Enter the **Blacksmith**. Speak to **Borin** to check weapons/armor shop.
   - Enter the **Apothecary**. Speak to **Nyssa** to start **Apothecary's Ingredients**.

4. **Fenwater Marsh (South of Outskirts)**:
   - Go south from Crafts to Outskirts, then south to Fenwater Marsh.
   - Find and collect 3 `marsh_root` items.
   - Return to Nyssa in the Apothecary to turn in the quest.

5. **Old Ward (North of Market)**:
   - Return to Market Square and head North.
   - Speak to **Olen** inside the Old House.
   - Enter the **Abandoned House** (northeast Old Ward).
   - Speak to **Vorn**.
   - Return to Olen in the Old House to complete **The Empty House**.

6. **Civic Quarter (East of Market)**:
   - Go East from Market to Civic.
   - Visit the **Elder's Hall** and **Temple** to observe distinct decorations and ambient acolytes.

7. **Save & Load Verification**:
   - Go to the **Bramble Inn** (northwest of Market Square).
   - Talk to **Silas** and purchase the **Rest and Recover** service to heal.
   - **Save** your game inside the Inn.
   - Close the game completely.
   - Reopen the game, click **Continue**, and ensure you spawn back in the Inn with all your quest completions and gold intact.
   - Note: If you load a save from before this expansion, you will spawn in Market Square instead of the old 'village' map.

## Completion Checklist
- [ ] All 5 districts visually identifiable
- [ ] 4 interior shops function correctly (General Store, Blacksmith, Apothecary, Inn)
- [ ] 4 new quests completable
- [ ] Ambient population wanders but respects collisions
- [ ] Game saves and restores correctly indoors
