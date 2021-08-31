extends Control


var current_money_for_spend = 0
var key = ""


func _ready():
	key = Global.items.keys()[0]
	
	update_items()


func update_items():
	# Загружаем сцену с самим предметом
	var Celler = load("res://Scenes/Cell_Items.tscn")
	var item = null
	
	# перебираем предметы по ключу
	for i in Global.inventory[key].keys():
		# добавляем товар в магазин
		item = Celler.instance()
		
		# выставляем все требуемые параметры
		item.text = i
		item.items_number = Global.inventory[key][i]
		item.price = Global.items[key][i]
		
		# добавляе товар на саму сцену магазина
		$Scroll/Container.add_child(item)
	
	# перебираем все возможные предметы
	for i in Global.items[key].keys():
		# добавляем товар
		item = Celler.instance()
		
		# выводим всю нужную инфу
		item.text = i
		item.items_number = 100
		item.price = Global.items[key][i]
			
		# добавляем на сцену товар
		$Scroll2/Container.add_child(item)


func clear_items():
	for i in $Scroll/Container.get_children():
		$Scroll/Container.remove_child(i)
	
	for i in $Scroll2/Container.get_children():
		$Scroll2/Container.remove_child(i)


# обработка нажатия на кнопку выхода
func _on_Exit_pressed():
	Global.goto_scene("res://Scenes/Menu.tscn")


# обработка нажатия на кнопку купить
func _on_Cell_pressed():
	# число удаленных предметов
	var deleted_items = 0
	
	# перебираем предметы в магазине (для продажи)
	for i in range($Scroll/Container.get_child_count()):
		# получаем узел
		var node = $Scroll/Container.get_child(i - deleted_items)
		
		# добавляем к денюшкам игрока ещё денег (число предметов на их стоимость)
		Global.money += node.price * node.current_items
		
		# Уменьшаем число предметов в инвентаре
		Global.inventory[key][node.text] -= node.current_items
		
		# ставим все по дефолту
		node.get_child(2).text = "0"
		node.items_number = Global.inventory[key][node.text]
		node.current_items = 0
		node.get_child(3).text = "Итого: 0"
		
		# если число предметов этих = 0
		if not Global.inventory[key][node.text]:
			# удаляем этот предмет из инвентаря и из сцены
			Global.inventory[key].erase(node.text)
			$Scroll/Container.remove_child(node)
			
			# увеличиваем число удаленных элементов на 1
			deleted_items += 1
	
	# Обновляем данные о деньгах
	$Coin/Money.text = str(Global.money)


func _on_Buy_pressed():
	# здесь все аналогично с продажей, только здесь вместо инвентаря все возможные предметы
	# обнуляем деньги, которые будут потрачены
	current_money_for_spend = 0
	
	for i in range($Scroll2/Container.get_child_count()):
		var node = $Scroll2/Container.get_child(i)
		
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


func _On_Price_changed(item, dir):
	# добавляем новую сумму денег к итоговой
	current_money_for_spend += item.price * dir
	
	# если у игрока не хватит денег, не даем купить предмет
	if current_money_for_spend > Global.money and dir > 0:
		current_money_for_spend -= item.price
		item.current_items -= 1
		item.get_child(2).text = str(item.current_items)
		item.get_child(3).text = "Итого" + str(item.current_items * item.price)


func _on_Type_Of_Item_type_changed(new_key):
	key = new_key
	
	clear_items()
	update_items()
