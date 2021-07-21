extends Control


# Обработка нажатия на кнопку старт
func _on_Start_pressed():
	Global.goto_scene("res://Scenes/Main.tscn")


# Обработка нажатия на кнопку информации
func _on_Info_pressed():
	Global.goto_scene("res://Scenes/Information.tscn")


# Обработка нажатия на кнопку магазин\
func _on_Shop_pressed():
	Global.goto_scene("res://Scenes/Shop.tscn")
