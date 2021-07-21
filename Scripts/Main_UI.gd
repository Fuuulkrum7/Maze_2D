extends Control


var default_time = 0	# Дефолтное время на восстановление прыжка
var current_time = 0	# Время до конца восстановления 
signal restart			# Сигнал для рестарта


func _ready():
	# Получаем таймер и время задержки
	var timer = Global._Player.get_child(2)
	default_time = int(timer.wait_time)


func _process(delta):
	# Обработка нажатия на escape
	if Input.is_action_just_pressed("ui_pause"):
		Continue()


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
