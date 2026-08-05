# BRAMBLEWICK LIVING TOWN EXPANSION PLAN

## 1. District Layout & Connection Graph

Bramblewick is expanded from a single generic village map into 5 distinct, connected districts:

1. **Market Square (village_market.json)** - The central hub.
   - Connections: West to Craftsmen's Row, North to Old Ward, East to Riverside, North-East to Civic Quarter, South to Outskirts.
2. **Craftsmen's Row (village_crafts.json)**
   - Connections: East to Market Square.
3. **Old Ward (village_old.json)**
   - Connections: South to Market Square.
4. **Riverside (village_river.json)**
   - Connections: West to Market Square.
5. **Temple and Civic Quarter (village_civic.json)**
   - Connections: South-West to Market Square.
6. **Outskirts (village_outskirts.json)**
   - Connections: North to Market Square, South to Darkwood / existing wilderness maps.

## 2. Enterable Buildings (12 Total)

1. **Market Square:**
   - Inn (b_inn.json)
   - General Store (b_general_store.json)
   - Bakery (b_bakery.json)
2. **Craftsmen's Row:**
   - Blacksmith (b_blacksmith.json)
   - Apothecary (b_apothecary.json)
   - Carpenter (b_carpenter.json)
3. **Old Ward:**
   - Old House (b_old_house.json)
   - Abandoned House (b_abandoned_house.json)
4. **Riverside:**
   - Mill (b_mill.json)
   - Warehouse (b_warehouse.json)
5. **Civic Quarter:**
   - Temple (b_temple.json)
   - Elder's Hall (b_elders_hall.json)
6. **Outskirts:**
   - Guardhouse (b_guardhouse.json)

## 3. NPC Roster (~23 Total)

**Existing:** Elder Maren, Borin (Smith), Ivo (Peddler), Aldith (Sister), Hobb (Miller)
**New:**
- Innkeeper Silas (Inn)
- Tavern Server Elara (Inn)
- Apprentice Smith Garret (Blacksmith)
- General Merchant Kael (General Store)
- Apothecary Nyssa (Apothecary)
- Guard Captain Kade (Guardhouse)
- Guard Fenn (Outskirts)
- Guard Rurik (Civic)
- Baker Liora (Bakery)
- Fisher Bran (Riverside)
- Stable Keeper Tor (Outskirts)
- Carpenter Yanni (Carpenter)
- Scholar Vane (Elder's Hall)
- Farmer Clem (Outskirts)
- Worried Parent Olen (Old Ward)
- Mischievous Child Pip (Market)
- Retired Adventurer Silas (Old House)
- Suspicious Stranger Vorn (Abandoned House)

## 4. Shop Roster & Implementation

Since current shopping is limited to hardcoded dialogue "buy" events, we will create the smallest reusable data-driven shop system.
- data/shops/shops.json: Defines shop inventories (NPC ID -> list of items).
- scripts/ui/shop_ui.gd & scenes/ui/shop_ui.tscn: A basic shop interface to list items, show prices, and buy.
- dialogue_ui.gd: Add "action": "open_shop" event to trigger the shop UI.

**Shops:**
1. Blacksmith Borin (Weapons & Armour)
2. General Merchant Kael (Supplies/Food/Consumables)
3. Apothecary Nyssa (Potions)
4. Innkeeper Silas (Rest/Food)
5. Peddler Ivo (Market Misc / Regional Goods)

## 5. Quest Roster (4 New)

1. **The Lost Delivery**
   - Giver: Kael (General Store)
   - Objective: Find Kael's missing package in the Riverside Warehouse.
   - Reward: Gold and items.
2. **Apothecary's Ingredients**
   - Giver: Nyssa (Apothecary)
   - Objective: Collect 3 Marsh Roots from Fenwater Marsh.
   - Reward: Healing potions.
3. **Trouble at the Mill**
   - Giver: Hobb (Miller)
   - Objective: Clear giant rats/spiders inside the Mill.
   - Reward: Gold.
4. **The Empty House**
   - Giver: Olen (Old Ward)
   - Objective: Investigate noises in the Abandoned House (find Vorn, dialogue resolution).
   - Reward: Gold and Lore.

## 6. File Ownership

- **Maps:** data/maps/village_*.json, data/maps/b_*.json
- **Data:** data/npcs/npcs.json, data/dialogue/*.json, data/quests/quests.json, data/items/items.json, data/shops/shops.json (New)
- **Code:** scripts/ui/shop_ui.gd, scenes/ui/shop_ui.tscn, modified dialogue_ui.gd and map_builder.gd.
- **Tests:** tests/test_town_integrity.gd (New), tests/test_playthrough.gd (Updated).

## 7. Implementation Order

1. **Maps & Navigation:**
   - Create the 5 district JSON maps and replace the old village.json references.
   - Create the 12 building interior JSON maps.
   - Connect all portals (Districts <-> Districts, Districts <-> Interiors).
2. **Data Definitions:**
   - Add the NPCs to npcs.json and place them on maps.
   - Add 4 new quests to quests.json.
   - Create dialogue files for new NPCs.
3. **Shop System:**
   - Create data/shops/shops.json.
   - Implement shop_ui.tscn and wire it to dialogue.
4. **Ambience & Verification:**
   - Add environmental details (fences, carts, water).
   - Expand test_runner.tscn to validate the new files.
   - Expand test_playthrough.gd integration test.
5. **Physical Test:** Export PCK and run manual physical verification.
