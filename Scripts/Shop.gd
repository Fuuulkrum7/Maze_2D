extends Control


var default_items_number = 0


func _ready():
	default_items_number = get_child_count()
	
	var Celler = load("res://Scenes/Cell_Items.tscn")
	var pos = 0.1
	for i in Global.inventory["items"].keys():
		var item = Celler.instance()
		item.anchor_left = 0.1
		item.anchor_top = pos
		
		item.text = i
		item.items_number = Global.inventory["items"][i]
		item.price = Global.items["items"][i]
		
		add_child(item)
		pos += 0.07
		


func _on_Exit_pressed():
	Global.goto_scene("res://Scenes/Menu.tscn")


func _on_Cell_pressed():
	var deleted_items = 0
	
	for i in range(default_items_number, get_child_count()):
		var node = get_child(i - deleted_items)
		
		var price = Global.items["items"][node.text]
		Global.money += price * node.current_items
		
		Global.inventory["items"][node.text] -= node.current_items
		
		node.get_child(2).text = "0"
		node.items_number = Global.inventory["items"][node.text]
		node.current_items = 0
		node.get_child(3).text = "Итого: 0"
		
		if not Global.inventory["items"][node.text]:
			Global.inventory["items"].erase(node.text)
			remove_child(node)
			
			deleted_items += 1
			
			for j in range(i - deleted_items + 1, get_child_count()):
				get_child(j).anchor_top -= 0.07
				get_child(j).anchor_bottom -= 0.07
	
	$Coin/Money.text = str(Global.money)
