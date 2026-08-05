extends Node

func _ready() -> void:
	print("Starting shop integration tests...")
	call_deferred("_run_tests")

func _run_tests() -> void:
	GameState.new_game("fighter", "Hero")
	
	print("Validating all shops exist...")
	var expected_shops = ["general_store", "blacksmith", "apothecary", "inn_rest", "bakery"]
	for s in expected_shops:
		assert(Db.shops.has(s), "Db.shops must contain " + s)
		
	var kael = Db.dialogues["kael"]
	var opens_shop = false
	for n_id in kael.get("nodes", {}):
		for opt in kael["nodes"][n_id].get("options", kael["nodes"][n_id].get("choices", [])):
			for ev in opt.get("events", []):
				# It might be kael_general_store now
				if ev.get("type") == "open_shop" and (ev.get("shop") == "general_store" or ev.get("shop") == "kael_general_store"):
					opens_shop = true
	assert(opens_shop, "Kael dialogue must emit open_shop for general_store")
	
	print("Testing shop logic...")
	var shop_ui = load("res://scenes/ui/shop_ui.tscn").instantiate()
	add_child(shop_ui)
	
	# Simulate opening general store
	shop_ui.open("general_store")
	assert(shop_ui.visible, "ShopUI should be visible")
	assert(shop_ui.shop_id == "general_store", "Shop ID should be set")
	
	# Affordable purchase
	Inventory.add_gold(100)
	var initial_gold = Inventory.get_gold()
	var torch_price = 2
	assert(Db.get_item("torch") != null, "Torch item must exist")
	# Fake the item click
	shop_ui._on_item_clicked("torch", torch_price, false)
	assert(Inventory.get_gold() == initial_gold - torch_price, "Gold should decrease")
	assert(Inventory.count("torch") == 1, "Should receive 1 torch")
	
	# Unaffordable purchase
	Inventory.spend_gold(Inventory.get_gold()) # set to 0
	shop_ui._on_item_clicked("torch", torch_price, false)
	assert(Inventory.get_gold() == 0, "Gold should remain 0")
	assert(Inventory.count("torch") == 1, "Should still have 1 torch")
	
	# Inn rest
	shop_ui.open("inn_rest")
	GameState.player["hp"] = 1
	Inventory.add_gold(5)
	shop_ui._on_item_clicked("rest", 5, true) # true means service
	assert(Inventory.get_gold() == 0, "Inn rest should cost 5 gold")
	assert(GameState.player["hp"] == GameState.player["hp_max"], "Inn rest should heal to max HP")
	
	# Unaffordable Inn rest
	GameState.player["hp"] = 1
	shop_ui._on_item_clicked("rest", 5, true)
	assert(GameState.player["hp"] == 1, "Inn rest should fail if no gold")
	
	shop_ui.close()
	assert(not shop_ui.visible, "ShopUI should close")
	
	print("PASS: Shop logic")
	print("ALL SHOP TESTS PASSED.")
	get_tree().quit(0)
