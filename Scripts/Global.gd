extends Node

var _Player
var _Camera
var _Spawn_pos
var current_scene = null
var money = 0
var inventory = {}
var items = {}
var version = "alpha 0.91"

const _Finish = preload("res://Scenes/Finish.tscn")
const _Spawn = preload("res://Scenes/SpawnPoint.tscn")
const _Ghost = preload("res://Scenes/Ghost.tscn")
const _Horse = preload("res://Scenes/Horse.tscn")


func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	load_game()


# переключение между сценами
func goto_scene(path):
	call_deferred("_deferred_goto_scene", path)


func _deferred_goto_scene(path):
	# It is now safe to remove the current scene
	current_scene.free()

	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instance()

	# Add it to the active scene, as child of root.
	get_tree().get_root().add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene() API.
	get_tree().set_current_scene(current_scene)


# Выбор случайного элемента списка
func choice(data):
	var lenght = len(data)
	var result = data[randi() % lenght]
	
	return result


# Сохранение файла
func save_file(content, path, is_json = false):
	var file = File.new()
	file.open(path, File.WRITE)
	
	if is_json:
		file.store_line(to_json(content))
	else:
		file.store_string(content)
	
	file.close()


# Загрузка файла
func load_file(path, user_data = false, is_json = false):
	var file = File.new()
	
	if not file.file_exists(path) and user_data:
		return false
	elif not file.file_exists(path):
		get_tree().quit()
	
	file.open(path, File.READ)
	
	var content = file.get_as_text()
	file.close()
	
	if is_json:
		content = parse_json(content)
	
	return content


func cipher(login):
	# будущий зашифрованый логин
	var new_login = ""
	
	# массив с ключами для шифровки
	var dict = {
		"0" : 65,
		"1" : 10,
		"2" : 41,
		"3" : 73,
		"4" : 82,
		"5" : 39,
		"6" : 17,
		"7" : 48,
		"8" : 23,
		"9" : 30
	}
	
	# перебираем логин
	for i in range(len(login)):
		# получаем по ключу значение из массива
		# возводим в 4 степень
		# и переводим в шестнадцатиричную систему счисления
		var a = pow(dict[login[i]], 4)
		a = "%x" % a
		
		# добавляем результат данных манипуляций к шифрованному логину
		new_login += a
		
		# если это не последняя цифра логина, добавляем разделитель
		if i != len(login) - 1:
			new_login += "g"
		
	
	# возвращаем новый логин
	return new_login



# дешифровшик
func recipher(login):
	# расшифрованый логин
	var new_login = ""
	var log_ = ""
	var log1 = []
	
	# Перебираем строку и разбиваем на части, в которые зашифрованы цифры
	for i in login:
		if i != "g":
			log_ += i
		else:
			log1.append(log_)
			log_ = ""
	
	login = log1
	login.append(log_)
	
	# ключи дешифровки
	var dict = {
		"65" : "0",
		"10" : "1",
		"41" : "2",
		"73" : "3",
		"82" : "4",
		"39" : "5",
		"17" : "6",
		"48" : "7",
		"23" : "8",
		"30" : "9"
	}
	
	# перебираем логин
	for i in range(len(login)):
		# переводим число в 10-ную систему счн
		var a = ("0x" + login[i]).hex_to_int()
		
		# вычисляем корень 4 cт.
		a = str(int(sqrt(sqrt(a))))
		
		# добавляем к логину число по ключу дешифровки
		new_login += dict[a]
	
	
	# возвращаем логин
	return new_login



# Загрузка данных для игры
func load_game():
	money = load_file("user://.money.dat", true)
	
	if money:
		money = recipher(money)
	
	var dir = Directory.new()
	
	if dir.file_exists("user://money.dat"):
		money = load_file("user://money.dat", true)
		dir.remove("user://money.dat")
	
	money = int(money)
	
	inventory = load_file("user://.inventory.json", true, true)
	items = load_file("res://Files/Items.json", false, true)
	var current_version = load_file("user://.version.dat", true)
	
	# если инвентаря ещё нет, создаем его
	if not inventory or version != current_version:
		print("new version")
		
		if not inventory:
			inventory = {}
		for key in items.keys():
			#if not inventory.has(key):
				inventory[key] = {
					
				}


# Сохранение игры 
func exit():
	save_file(cipher(str(money)), "user://.money.dat")
	save_file(version, "user://.version.dat")
	save_file(inventory, "user://.inventory.json", true)
	get_tree().quit() # default behavior


# Обработка выхода из игры
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		exit()
