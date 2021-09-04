extends Control


var default_time = 0	# Дефолтное время на восстановление прыжка
var current_time = 0	# Время до конца восстановления 
signal restart			# Сигнал для рестарта

var usefull_items = []
var items = [preload("res://Scenes/Potion.tscn"), 
			 preload("res://Scenes/Pistol.tscn")]

var current_item = ""
var potions_animation = {
	"Зелье заморозки": "Blue", 
	"Зелье ускорения": "Yellow", 
	"Зелье замедления врага": "Green",
}
var containers = []


func _ready():
	# Получаем таймер и время задержки
	var timer = Global._Player.get_child(2)
	default_time = int(timer.wait_time)
	
	usefull_items += Global.inventory["potion"].keys()
	
	var weapon = Global.inventory["weapon"].keys()
	
	var i = weapon.rfind("Серебряная пуля")
	weapon.remove(i)
	
	if len(weapon):
		usefull_items.append(weapon[-1])
	
	for j in range(len(usefull_items)):
		var container = $Inventory.get_child(j)
		
		containers.append(container)
		
		var item
		
		if potions_animation.has(usefull_items[j]):
			container.get_child(0).text = str(Global.inventory["potion"][usefull_items[j]])
			
			item = items[0].instance()
			item.animation = potions_animation[usefull_items[j]]
		else:
			container.get_child(0).text = str(Global.inventory["weapon"][usefull_items[j]])
			item = items[1].instance()
		
		container.add_child(item)
	
	change_item(0)


func change_item(index):
	if len(usefull_items) > index:
		current_item = usefull_items[index]
		$Inventory.show_type(current_item)


func _input(event):
	# Обработка нажатия на escape
	if event.is_action_pressed("ui_pause"):
		Continue()
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_1:
			change_item(0)
		if event.scancode == KEY_2:
			change_item(1)
		if event.scancode == KEY_3:
			change_item(2)
		if event.scancode == KEY_4:
			change_item(3)
	
	# if event is InputEventMouseButton:
	
	if event.is_action_pressed("ui_use") and potions_animation.has(current_item):
		if Global.inventory["potion"].has(current_item):
			Global.inventory["potion"][current_item] -= 1
			
			var main = Global._Camera.get_parent()
			containers[usefull_items.find(current_item)].get_child(0).text = str(Global.inventory["potion"][current_item])
			
			if current_item == "Зелье заморозки" and $Freeze.is_stopped(): 
				main.mob.paused = true
				$Freeze.start()
			
			elif current_item == "Зелье ускорения" and $Speed.is_stopped():
				Global._Player.max_speed *= 1.5
				$Speed.start()
			
			elif current_item == "Зелье замедления врага" and $Slow_Enemy.is_stopped():
				if main.mob.name == "Horse":
					main.get_child(0).character_speed /= 2
				else:
					main.mob.speed /= 1.5
				$Slow_Enemy.start()
			
			if Global.inventory["potion"][current_item] == 0:
				Global.inventory["potion"].erase(current_item)
				containers[usefull_items.find(current_item)].get_child(1).animation = "Default"
	
	# сохраняем инвентарь
	Global.save_file(Global.inventory, "user://.inventory.json", true)


# Отображение таймера восстановления
func Show_Timer():
	# Ставим время
	current_time = default_time
	
	# Вкючаем отображения самого таймера
	$Rest_Timer.visible = true
	$Rest_Timer.text = str(default_time)
	
	# Запуск односекундного таймера
	$One_Second.start()


func _on_One_Second_timeout():
	# Уменьшаем таймер на секунду
	current_time -= 1
	
	# Если таймер больше 0
	if current_time > 0:
		# Обновляем таймер и запускаем его
		$Rest_Timer.text = str(current_time)
		$One_Second.start()
	 # Если таймер закончился, прячем его
	else:
		$Rest_Timer.visible = false


# Прячет/отображает кнопки, ставит игру на паузу
func Continue():
	$Continue.visible = not $Continue.visible
	get_tree().paused = not get_tree().paused
	$Restart.visible = not $Restart.visible
	$Exit.visible = not $Exit.visible
	$Key.visible = not $Key.visible
	$Inventory.visible = not $Inventory.visible


# Перезапуск уровня
func _on_Restart_pressed():
	# Ставим время восстановления прыжка на 0 и прячем таймер
	current_time = 0
	$Rest_Timer.visible = false
	
	# прячем кнопки и даем сигнал о том, что нужен рестарт
	Continue()
	$Continue.visible = false
	emit_signal("restart")


# Выход из игры
func _on_Exit_pressed():
	get_tree().paused = false
	Global.goto_scene("res://Scenes/Menu.tscn")


# Вызывается при входе игрока на финиш
func Finish():
	$Win_Text.visible = true
	$Finish_Timer.start()
	get_tree().paused = true


# Сам финиш
func _on_Finish_Timer_timeout():
	$Win_Text.visible = false
	Continue()
	$Continue.visible = false
	get_tree().paused = true


func _on_Freeze_timeout():
	Global._Camera.get_parent().mob.paused = false


func _on_Speed_timeout():
	Global._Player.max_speed /= 1.5


func _on_Slow_Enemy_timeout():
	var main = Global._Camera.get_parent()
	if main.mob.name == "Horse":
		main.get_child(0).character_speed *= 2
	else:
		main.mob.speed *= 1.5
