extends Node

func _ready() -> void:
	print("Starting shop integration tests...")
	call_deferred("_run_tests")

func _run_tests() -> void:
	GameState.new_game("fighter", "Hero")
	
	print("Validating all shops exist...")
	var expected_shops = ["borin_blacksmith", "kael_general_store", "nyssa_apothecary", "silas_inn", "ivo_peddler"]
	for s in expected_shops:
		assert(Db.shops.has(s), "Db.shops must contain " + s)
		
	var kael = Db.dialogues["kael"]
	var opens_shop = false
	for n_id in kael.get("nodes", {}):
		for opt in kael["nodes"][n_id].get("options", kael["nodes"][n_id].get("choices", [])):
			for ev in opt.get("events", []):
				if ev.get("type") == "open_shop" and ev.get("shop") == "kael_general_store":
					opens_shop = true
	assert(opens_shop, "Kael dialogue must emit open_shop for kael_general_store")
	
	print("Testing shop logic...")
	var shop_ui = load("res://scenes/ui/shop_ui.tscn").instantiate()
	add_child(shop_ui)
	
	# Simulate opening general store via actual API
	EventBus.shop_requested.emit("kael_general_store")
	assert(shop_ui.visible, "ShopUI should be visible")
	assert(shop_ui._shop_id == "kael_general_store", "Shop ID should be set")
	
	# Find the item button for potion_healing
	var buy_btn = null
	for c in shop_ui._items_box.get_children():
		if c is Button and "Healing Potion" in c.text:
			buy_btn = c
			break
	assert(buy_btn != null, "Buy button for Healing Potion should exist")
	
	# Affordable purchase
	Inventory.add_gold(100)
	var initial_gold = Inventory.gold
	var initial_potions = Inventory.count("potion_healing")
	var potion_price = 8
	assert(Db.get_item("potion_healing") != null, "Potion item must exist")
	buy_btn.pressed.emit()
	await get_tree().process_frame
	assert(Inventory.gold == initial_gold - potion_price, "Gold should decrease")
	assert(Inventory.count("potion_healing") == initial_potions + 1, "Should receive 1 potion")
	
	# Unaffordable purchase
	Inventory.spend_gold(Inventory.gold) # set to 0
	
	buy_btn = null
	for c in shop_ui._items_box.get_children():
		if c is Button and "Healing Potion" in c.text:
			buy_btn = c
			break
	
	buy_btn.pressed.emit()
	await get_tree().process_frame
	assert(Inventory.gold == 0, "Gold should remain 0")
	assert(Inventory.count("potion_healing") == initial_potions + 1, "Should still have same potion count")
	
	# Close button
	var close_btn = null
	for c in shop_ui._items_box.get_children():
		if c is Button and "Close Shop" in c.text:
			close_btn = c
			break
	assert(close_btn != null, "Close button should exist")
	close_btn.pressed.emit()
	assert(not shop_ui.visible, "ShopUI should close")
	
	# Inn rest
	EventBus.shop_requested.emit("silas_inn")
	GameState.player["hp"] = 1
	Inventory.add_gold(5)
	
	var rest_btn = null
	for c in shop_ui._items_box.get_children():
		if c is Button and "Rest and Recover" in c.text:
			rest_btn = c
			break
	assert(rest_btn != null, "Rest button should exist")
	rest_btn.pressed.emit()
	assert(Inventory.gold == 0, "Inn rest should cost 5 gold")
	assert(GameState.player["hp"] == GameState.player["hp_max"], "Inn rest should heal to max HP")
	
	shop_ui.queue_free()
	print("PASS: Shop logic")
	print("ALL SHOP TESTS PASSED.")
	get_tree().quit(0)
