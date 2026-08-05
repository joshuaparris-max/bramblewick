extends CanvasLayer

var _panel: PanelContainer
var _name_lbl: Label
var _gold_lbl: Label
var _items_box: VBoxContainer
var _shop_id: String

func _ready() -> void:
	layer = 15
	_build_ui()
	visible = false
	EventBus.shop_requested.connect(start)

func start(shop_id: String) -> void:
	var def = Db.shops.get(shop_id)
	if def == null:
		return
	_shop_id = shop_id
	visible = true
	_name_lbl.text = def.get("id", shop_id).replace("_", " ").capitalize()
	_update_ui()

func _update_ui() -> void:
	_gold_lbl.text = "Your Gold: %d" % Inventory.gold
	for c in _items_box.get_children():
		c.queue_free()
		
	var def = Db.shops[_shop_id]
	for s in def.get("stock", []):
		var item = Db.get_item(s["item"])
		var btn = Button.new()
		btn.text = "%s (%dg)" % [item.get("name", s["item"]), s["cost"]]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.disabled = Inventory.gold < s["cost"]
		btn.pressed.connect(_on_buy_item.bind(s["item"], s["cost"]))
		_items_box.add_child(btn)
		
	for serv in def.get("services", []):
		var btn = Button.new()
		btn.text = "%s (%dg)" % [serv["name"], serv["cost"]]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.disabled = Inventory.gold < serv["cost"]
		btn.pressed.connect(_on_buy_service.bind(serv["event"], serv["cost"]))
		_items_box.add_child(btn)
		
	var close_btn = Button.new()
	close_btn.text = "(Close Shop)"
	close_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	close_btn.pressed.connect(_close)
	_items_box.add_child(close_btn)

func _on_buy_item(item_id: String, cost: int) -> void:
	if Inventory.spend_gold(cost):
		Inventory.add(item_id, 1)
		EventBus.toast.emit("Bought item.")
		_update_ui()
	else:
		EventBus.toast.emit("Not enough gold.")

func _on_buy_service(event: String, cost: int) -> void:
	if Inventory.spend_gold(cost):
		if event == "heal_full":
			GameState.heal_full()
			EventBus.toast.emit("Fully rested.")
		_update_ui()
	else:
		EventBus.toast.emit("Not enough gold.")

func _close() -> void:
	visible = false

func _build_ui() -> void:
	_panel = PanelContainer.new()
	_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	_panel.offset_left = 60
	_panel.offset_right = -60
	_panel.offset_top = 60
	_panel.offset_bottom = -60
	add_child(_panel)
	
	var v = VBoxContainer.new()
	_panel.add_child(v)
	
	_name_lbl = Label.new()
	_name_lbl.add_theme_color_override("font_color", Color("e8b45a"))
	_name_lbl.add_theme_font_size_override("font_size", 24)
	v.add_child(_name_lbl)
	
	_gold_lbl = Label.new()
	v.add_child(_gold_lbl)
	
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(scroll)
	
	_items_box = VBoxContainer.new()
	_items_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_items_box)
