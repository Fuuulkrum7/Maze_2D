extends TileMap

# поле
var field = []

# клетки,которые надо посетить
var need_to_visit = []

# начальные х и у
var new_X_and_Y = []
# координата по оси х
var now_x = 0
# и у
var now_y = 0
# проденный в лабиринте путь
var way = []

func choice(data):
	randomize()
	var lenght = len(data)
	var result = data[randi() % lenght]
	
	return result

func create(width, height):
	# делаем заготовку из -1
	for _y in range(height):
		var sth = []
		for _x in range(width):
			sth.append(-1)
		field.append(sth)
	
	# меняем, где надо, -1 на стену 0 и место, которое надо посетить на 1
	for y in range(1, len(field) - 1):
		for x in range(1, len(field[y]) - 1):
			if x % 2 != 0 and y % 2 != 0:
				field[y][x] = 1
			else:
				field[y][x] = 0

	# чистим список на всякий случай (точнее, на случай повторной генерации лабиринта)
	need_to_visit = []

	# заполняем его координатами единиц из поля
	for x in range(len(field)):
		for y in range(len(field[x])):
			if field[x][y] == 1:
				need_to_visit.append([x, y])
	

	# выбираем начальную клетку
	new_X_and_Y = choice(need_to_visit)

	# определяем х
	now_x = new_X_and_Y[0]

	# и у
	now_y = new_X_and_Y[1]

	# чистим путь
	way = []
	
	var coord = need_to_visit.find([now_x, now_y])
	need_to_visit.remove(coord)


# получаем координаты соседей
func getNeighbors(_now_x, _now_y, now_field):
	# список координат соседей
	var neighbors = []

	# если подходит по условию клетка, то добавляем ее в список
	# проверка работает так - рассматриваем клетки, где х или у координата больше или меньше на два
	# то есть клетка выше нынешней на одну, ниже на одну, слева  и справа через одну
	# если такая координата есть в списке тех, которые надо посетить, добавляем ее туда.
	if [_now_x, _now_y - 2] in need_to_visit:
		neighbors.append([_now_x, _now_y - 2, 0, -1])

	if [_now_x + 2, _now_y] in need_to_visit:
		neighbors.append([_now_x + 2, _now_y, 1, 0])

	if [_now_x, _now_y + 2] in need_to_visit:
		neighbors.append([_now_x, _now_y + 2, 0, 1])

	if [_now_x - 2, _now_y] in need_to_visit:
		neighbors.append([_now_x - 2, _now_y, -1, 0])

	# возвращаем в метод, создающий лабиринт координаты соседних НЕПОСЕЩЕННЫХ клеток
	return neighbors


func createMaze(width, height):
	# создаем заготовки под лабиринт
	create(width, height)

	while len(need_to_visit) > 0:
		# получаем координаты соседей
		var now_neighbors = getNeighbors(now_x, now_y, field)
		
		# если соседи есть
		if len(now_neighbors) > 0:
			# выбираем одного из них
			var new_x_y = choice(now_neighbors)

			# извлекаем будущие координаты
			var new_x = new_x_y[0]
			var new_y = new_x_y[1]

			# убираем стену между клеткой, на которой мы сейчас и той, куда встанем
			field[now_x + new_x_y[2]][now_y + new_x_y[3]] = 1

			# добавляем новые координаты в "путь"
			way.append([now_x, now_y])

			# обновляем данные о том, на какой мы клетке
			now_x = new_x
			now_y = new_y
			
			# если клетка в непосещенных - удаляем ее
			var coord = need_to_visit.find([now_x, now_y])
			need_to_visit.remove(coord)

		elif len(way) != 0:  # если соседей нет и можно отойти назад по пути
			# меняем нынешние координаты на предыдущие
			var new = way[-1]
			now_x = new[0]
			now_y = new[1]

			# удаляем их
			way.remove(len(way) - 1)
		else:  # иначе выбираем случайную клетку из непосещенных
			var new = choice(need_to_visit)
			now_x = new[0]
			now_y = new[1]

	# сохраняем поле
	var new_field = field

	# чистим поле
	field = []

	# возвращаем лабиринт
	return new_field
