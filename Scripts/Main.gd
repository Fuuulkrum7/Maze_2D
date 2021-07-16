extends Node2D

export(int) var WIDTH = 0		# ширина лабиринта
export(int) var HEIGHT = 0		# высота лабирина

var maze = []					# заготовка под лабиринт

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

func _ready():
	Show_maze()
	
	# ставим на требуемые места старт и финиш
	var Spawn = Global._Spawn.instance()
	Spawn.position = Vector2(96, 96)
	Global._Spawn_pos = Spawn.position
	add_child(Spawn)
	
	var Finish = Global._Finish.instance()
	Finish.position = Vector2((WIDTH - 2) * 64 + 32, (HEIGHT - 2) * 64 + 32)
	add_child(Finish)

func _On_body_entered(body):
	# функция рестарта
	Global._Player.position = Global._Spawn_pos
	Show_maze()
