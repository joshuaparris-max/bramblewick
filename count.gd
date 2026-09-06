extends Node

func _ready() -> void:
	call_deferred("_count")

func _count() -> void:
	Db.load_all()
	
	var districts = 0
	var interiors = 0
	for m in Db.maps:
		if m.begins_with("village_"): districts += 1
		elif m.begins_with("b_"): interiors += 1
		
	var named_npcs = 0
	var ambient_npcs = 0
	for n in Db.npcs:
		if n.begins_with("amb_"): ambient_npcs += 1
		else: named_npcs += 1
		
	print("Districts: ", districts)
	print("Interiors: ", interiors)
	print("Named NPCs: ", named_npcs)
	print("Ambient NPCs: ", ambient_npcs)
	print("Shops: ", Db.shops.size())
	
	var town_quests = 0
	for q in Db.quests:
		if q.begins_with("q_"): town_quests += 1
	print("Quests: ", town_quests)
	get_tree().quit(0)
