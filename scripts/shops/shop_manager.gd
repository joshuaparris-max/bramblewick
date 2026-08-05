extends Node

func open_shop(shop_id: String) -> void:
	if Db.shops.has(shop_id):
		EventBus.shop_requested.emit(shop_id)
	else:
		push_error("Unknown shop: " + shop_id)
