extends Node2D

export(int) var WIDTH = 0		# ширина лабиринта
export(int) var HEIGHT = 0		# высота лабирина

var maze = []					# заготовка под лабиринт
var has_key = false				# есть ли ключ
var items = []					# заготовка под найденный пример
var mob = null					# заготовка под моба
var small_chests = []			# заготовка под сундуки

# Заготовки под изображения ключа и сундука
var closed_chest = preload("res://Sprites/Chest0.png")
var ghost_key = preload("res://Sprites/Key0.png")
var normal_key = preload("res://Sprites/Key1.png")
var small_chest = preload("res://Scenes/Small_Chest.tscn")

func Show_maze():
	# создаем лабиринт
	maze = $Navigation/Maze.createMaze(WIDTH, HEIGHT)
	
	# перебираем лабиринт и выводим его на экран
	for y in range(len(maze)):
		for x in range(len(maze[y])):
			if maze[y][x] == -1:
				$Navigation/Maze_Border.set_cellv(Vector2(x, y), 0)
			elif maze[y][x] == 0:
				$Navigation/Maze.set_cellv(Vector2(x, y), 0)
			else:
				$Navigation/Maze.set_cellv(Vector2(x, y), 1)
	
	# Выбираем позицию для моба и сундука
	var chest_pos = Vector2((int((randi() % int(WIDTH * 0.6) + WIDTH * 0.2) / 2) * 2 + 1) * 64,
							(int((randi() % int(HEIGHT * 0.6) + HEIGHT * 0.2) / 2) * 2 + 1) * 64)
	
	chest_pos += Vector2(32, 32)
	
	# добавляем моба(и выбираем его)
	mob = Global.choice([Global._Horse, Global._Ghost]).instance()
	$Navigation.ghost = (mob.name == "Ghost")
	$Navigation.character = mob
	$Navigation.start_pos = chest_pos
	
	# Ставим моба и сундук на позиции
	mob.position = chest_pos
	add_child(mob)
	print(mob.name)
	
	$Chest.position = chest_pos
	
	# удаляем старые мини-сундуки
	for item in small_chests:
		remove_child(item)
	
	# чистим список с сундуками
	small_chests.clear()
	
	for i in range(2):
		for j in range(2):
			# создаем вероятность 1 к 3 спавна сундука
			if randi() % 3:
				# выбираем позицию под сундук
				chest_pos = Vector2((int((randi() % int(WIDTH * 0.3) + int(WIDTH * 0.1) + int(WIDTH * 0.5 * i)) / 2 ) * 2 + 1)* 64 + 32,
									(int((randi() % int(HEIGHT * 0.3) + int(HEIGHT * 0.1) + int(HEIGHT * 0.5 * j)) / 2) * 2 + 1) * 64 + 32)
				
				# добавляем сундук на карту
				var new_chest = small_chest.instance()
				new_chest.position = chest_pos
				add_child(new_chest)
				
				# добавляем сундук в список
				small_chests.append(new_chest)
	
	# задаем дефолтные данные
	print(len(small_chests))
	has_key = false
	items.clear()


func _ready():
	randomize()
	
	# ставим на требуемые места старт и финиш
	var Spawn = Global._Spawn.instance()
	Spawn.position = Vector2(96, 96)
	Global._Spawn_pos = Spawn.position
	add_child(Spawn)
	
	var Finish = Global._Finish.instance()
	Finish.position = Vector2((WIDTH - 2) * 64 + 32, (HEIGHT - 2) * 64 + 32)
	add_child(Finish)
	
	# готовим лабиринт
	Show_maze()


func Restart():
	# ставим игрока на старт, возвращаем возможность игроку прыгать
	# и удаляем моба
	Global._Player.position = Global._Spawn_pos
	Global._Player.can_jump = true
	$Camera/Main_UI.current_time = 0
	remove_child(mob)
	
	# меняем лабиринт
	Show_maze()
	# ставим дефолтные текстуры сундука и ключа
	$Camera/Main_UI/Key.texture = ghost_key
	$Chest/Sprite.texture = closed_chest


func _On_body_entered(body):
	# функция рестарта
	if has_key:
		# перебираем найденные предмета
		for item in items:
			# если такой предмет уже есть, увеличиваем их число
			if Global.inventory[item[1]].has(item[0]):
				Global.inventory[item[1]][item[0]] += 1
			# иначе добавляем его в инвентарь
			else:
				Global.inventory[item[1]][item[0]] = 1
		
		# сохраняем инвентарь
		Global.save_file(Global.inventory, "user://.inventory.json", true)
		
		# запускаем финиш
		$Camera/Main_UI.Finish()


# функция, обрабатывающая столкновение врага и игрока
func _On_enemy_entered(body):
	if body == Global._Player:
		# Запускаем скрипт паузы и вырубаем кнопку продолжить
		$Camera/Main_UI.Continue()
		$Camera/Main_UI/Continue.visible = false


# обработка столкновения игрока и сундука
func _On_Chest_entered(body):
	if body == Global._Player and not has_key:
		has_key = true
		
		# если моб есьм конь, ускоряем его и заставляем (бедненький конь) 
		# гнаться за игроком
		if mob.name == "Horse":
			mob.chest_closed = false
			$Navigation.speed = 1.5 * $Navigation.character_speed
		
		# ставим текстуру ключа
		$Camera/Main_UI/Key.texture = normal_key
		
		# Выбираем предмет из сундука
		var item = Global.choice(Global.items["items"].keys())
		
		items.append([item, "items"])
		
		# формируем строку
		var found = """Найдено:
			Ключ
			%s""" % item
		
		# отображаем, что нашли
		$Camera/Main_UI/Found_Items.text = found
		$Camera/Main_UI/Items_Timer.start()


# обработка столкновения с маленьким сундуком
func _On_Small_Chest_entered(body):
	if body == Global._Player:
		# Выбираем предмет из сундука
		var item = Global.choice(Global.items["small_items"].keys())
		
		# добавляем предмет в список самих найденных предметов
		items.append([item, "small_items"])
		
		# формируем строку
		var found = """Найдено:
			%s""" % item
		
		# отображаем найденный предмет
		$Camera/Main_UI/Found_Items.text = found
		$Camera/Main_UI/Items_Timer.start()


# если игрок застрял в лабиринте
func _on_Player_maze_entered():
	# получаем позицию игрока и трансформируем ее в позицию в лабиринте
	var pos = Global._Player.position / 64
	pos = Vector2(int(pos.x), int(pos.y))
	
	# если игрок точно застрял, ищем соседние свободные клетки и перемещаем его туда
	if maze[pos.y][pos.x] == 0:
		var neighbours = find_neighbours(pos)
		var neib = Global.choice(neighbours)
		Global._Player.position = neib


# ищем соседей
func find_neighbours(pos):
	# список для соседей
	var neighbours = []
	
	# перебираем соседние позиции в поисках свободных
	for i in range(3):
		for j in range(3):
			if maze[pos.y - 1 + i][pos.x - 1 + j] == 1:
				neighbours.append(Vector2((pos.x - 1 + j) * 64, 
										  (pos.y - 1 + i) * 64))
	
	# возвращаем список с суседями
	return neighbours
