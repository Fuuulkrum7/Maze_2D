extends Node

var _Player
var _Camera
var _Spawn_pos
var current_scene = null
var money = 0
var inventory = {}
var items = {}
var version = "alpha 0.9"

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


# Загрузка данных для игры
func load_game():
	money = int(load_file("user://money.dat", true))
	inventory = load_file("user://inventory.json", true, true)
	items = load_file("res://Files/Items.json", false, true)
	var current_version = load_file("user://version.dat", true)
	
	# если инвентаря ещё нет, создаем его
	if not inventory or version != current_version:
		print("new version")
		
		if not inventory:
			inventory = {}
		for key in items.keys():
			if not inventory.has(key):
				inventory[key] = {
					
				}


# Сохранение игры 
func exit():
	save_file(str(money), "user://money.dat")
	save_file(version, "user://version.dat")
	save_file(inventory, "user://inventory.json", true)
	get_tree().quit() # default behavior


# Обработка выхода из игры
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		exit()
