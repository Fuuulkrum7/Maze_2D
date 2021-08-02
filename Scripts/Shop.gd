extends Control


var current_money_for_spend = 0


func _ready():
	var Celler = load("res://Scenes/Cell_Items.tscn")
	
	for key in Global.inventory.keys():
		for i in Global.inventory[key].keys():
			var item = Celler.instance()
		
			item.text = i
			item.items_number = Global.inventory[key][i]
			item.price = Global.items[key][i]
		
			$Scroll/Container.add_child(item)
		
	for key in Global.items.keys():
		for i in Global.items[key].keys():
			var item = Celler.instance()
		
			item.text = i
			item.items_number = 100
			item.price = Global.items[key][i]
		
			$Scroll2/Container.add_child(item)


func _on_Exit_pressed():
	Global.goto_scene("res://Scenes/Menu.tscn")


func _on_Cell_pressed():
	var deleted_items = 0
	
	var all_keys = Global.inventory.keys()
	var key = all_keys[0]
	var count = len(Global.inventory[key])
	var index = 0
	
	for i in range($Scroll/Container.get_child_count()):
		var node = $Scroll/Container.get_child(i - deleted_items)
		
		if count < i + 1:
			index += 1
			key = all_keys[index]
			count += len(Global.inventory[key])
		
		Global.money += node.price * node.current_items
		
		Global.inventory[key][node.text] -= node.current_items
		
		node.get_child(2).text = "0"
		node.items_number = Global.inventory[key][node.text]
		node.current_items = 0
		node.get_child(3).text = "Итого: 0"
		
		if not Global.inventory[key][node.text]:
			Global.inventory[key].erase(node.text)
			$Scroll/Container.remove_child(node)
			
			deleted_items += 1
			
			for j in range(i - deleted_items + 1, $Scroll/Container.get_child_count()):
				$Scroll/Container.get_child(j).anchor_top -= 0.07
				$Scroll/Container.get_child(j).anchor_bottom -= 0.07
	
	$Coin/Money.text = str(Global.money)


func _on_Buy_pressed():
	var all_keys = Global.items.keys()
	var key = all_keys[0]
	var count = len(Global.items[key])
	var index = 0
	
	for i in range($Scroll2/Container.get_child_count()):
		var node = $Scroll2/Container.get_child(i)
		
		if count < i + 1:
			index += 1
			key = all_keys[index]
			count += len(Global.items[key])
		
		var price = Global.items[key][node.text]
		Global.money -= price * node.current_items
		
		if node.current_items > 0:
			if Global.inventory[key].has(node.text):
				Global.inventory[key][node.text] += node.current_items
				
				for n in $Scroll/Container.get_children():
					if n.text == node.text:
						n.items_number = Global.inventory[key][node.text]
			else:
				Global.inventory[key][node.text] = node.current_items
				var item = load("res://Scenes/Cell_Items.tscn").instance()
				
				item.text = node.text
				item.items_number = Global.inventory[key][node.text]
				item.price = Global.items[key][node.text]
		
				$Scroll/Container.add_child(item)
		
		node.get_child(2).text = "0"
		node.current_items = 0
		node.get_child(3).text = "Итого: 0"
	
	$Coin/Money.text = str(Global.money)


func _On_Price_changed(item):
	current_money_for_spend += item.price
	
	if current_money_for_spend > Global.money:
		current_money_for_spend -= item.price
		item.current_items -= 1
		item.get_child(2).text = str(item.current_items)
		item.get_child(3).text = "Итого" + str(item.current_items * item.price)
