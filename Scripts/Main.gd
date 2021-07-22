extends Node2D

export(int) var WIDTH = 0		# ширина лабиринта
export(int) var HEIGHT = 0		# высота лабирина

var maze = []					# заготовка под лабиринт
var has_key = false				# есть ли ключ
var items = []					# заготовка под найденный пример

# Заготовки под изображения ключа и сундука
var closed_chest = preload("res://Sprites/Chest0.png")
var opened_chest = preload("res://Sprites/Chest1.png")
var ghost_key = preload("res://Sprites/Key0.png")
var normal_key = preload("res://Sprites/Key1.png")

func Show_maze():
	# создаем лабиринт
	maze = $Maze.createMaze(WIDTH, HEIGHT)
	
	# перебираем лабиринт и выводим его на экран
	for y in range(len(maze)):
		for x in range(len(maze[y])):
			if maze[y][x] == -1:
				$Maze_Border.set_cellv(Vector2(x, y), 0)
			elif maze[y][x] == 0:
				$Maze.set_cellv(Vector2(x, y), 0)
			else:
				$Maze.set_cellv(Vector2(x, y), 1)
	
	# Выбираем позицию для моба и сундука
	var chest_pos = Vector2((int((randi() % int(WIDTH * 0.6) + WIDTH * 0.2) / 2) * 2 + 1) * 64,
							(int((randi() % int(HEIGHT * 0.6) + HEIGHT * 0.2) / 2) * 2 + 1) * 64)
	
	# Ставим моба и сундук на позиции
	$Ghost.position = chest_pos
	chest_pos += Vector2(32, 25.5)
	$Chest.position = chest_pos
	
	has_key = false
	items.clear()


func _ready():
	randomize()
	Show_maze()
	
	# ставим на требуемые места старт и финиш
	var Spawn = Global._Spawn.instance()
	Spawn.position = Vector2(96, 96)
	Global._Spawn_pos = Spawn.position
	add_child(Spawn)
	
	var Finish = Global._Finish.instance()
	Finish.position = Vector2((WIDTH - 2) * 64 + 32, (HEIGHT - 2) * 64 + 32)
	add_child(Finish)


func Restart():
	Global._Player.position = Global._Spawn_pos
	Show_maze()
	$Camera/Main_UI/Key.texture = ghost_key
	$Chest/Sprite.texture = closed_chest


func _On_body_entered(body):
	# функция рестарта
	if has_key:
		for item in items:
			if Global.inventory["items"].has(item):
				Global.inventory["items"][item] += 1
			else:
				Global.inventory["items"][item] = 1
		
		$Camera/Main_UI.Finish()


func _On_enemy_entered(body):
	if body == Global._Player:
		$Camera/Main_UI.Continue()
		$Camera/Main_UI/Continue.visible = false


func _On_Chest_entered(body):
	if body == Global._Player and not has_key:
		has_key = true
		$Camera/Main_UI/Key.texture = normal_key
		$Chest/Sprite.texture = opened_chest
		
		# Выбираем предмет из сундука
		var item = Global.choice(Global.items["items"].keys())
		
		items.append(item)
		
		var found = """Найдено:
			Ключ
			%s""" % item
		
		$Camera/Main_UI/Found_Items.text = found
		$Camera/Main_UI/Items_Timer.start()


func _on_Player_maze_entered():
	var pos = Global._Player.position / 64
	pos = Vector2(int(pos.x), int(pos.y))
	
	if maze[pos.y][pos.x] == 0:
		var neighbours = find_neighbours(pos)
		var neib = Global.choice(neighbours)
		Global._Player.position = neib


func find_neighbours(pos):
	var neighbours = []
	for i in range(3):
		for j in range(3):
			if maze[pos.y - 1 + i][pos.x - 1 + j] == 1:
				neighbours.append(Vector2((pos.x - 1 + j) * 64, 
										  (pos.y - 1 + i) * 64))
	
	return neighbours
