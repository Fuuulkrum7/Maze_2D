extends Navigation2D

export(float) var character_speed = 200.0
export(float) var max_distance = 2000

var path = []
var distance_ = 0
var start_pos = Vector2()
var speed = 0
var ghost = true

onready var character


func _ready():
	speed = character_speed
	set_process(true)


func _process(delta):
	if not ghost:
		_update_navigation_path(character.position, Global._Player.position)
		var walk_distance = speed * delta
	
		if distance_ and not character.paused:
			move_along_path(walk_distance)


func move_along_path(distance):
	var last_point = character.position
	while path.size():
		if len(path) > 0:
			if path[0].x > last_point.x:
				character.get_child(0).play("Move_Right")
			else:
				character.get_child(0).play("Move_Left")
		
		var distance_between_points = last_point.distance_to(path[0])
		
		# The position to move to falls between two points.
		if distance <= distance_between_points:
			character.position = last_point.linear_interpolate(path[0], distance / distance_between_points)
			return
		# The position is past the end of the segment.
		distance -= distance_between_points
		last_point = path[0]
		path.remove(0)
		
	if path.size() == 0 and character.get_child(0).animation != "Standart":
		character.get_child(0).play("Standart")
	character.position = last_point


func _update_navigation_path(start_position, end_position):
	path = get_simple_path(start_position, end_position, true)
	distance_ = _get_distance(path)
	
	if character.chest_closed:
		speed = character_speed
	
	if distance_ > max_distance and character.chest_closed:
		path = get_simple_path(start_position, start_pos, true)
		distance_ = _get_distance(path)
		speed = character_speed / 1.5
	
	path.remove(0)


func _get_distance(way):
	var start_pos = way[0]
	var dist = 0
	for i in range(1, len(way)):
		dist += sqrt((start_pos.x - way[i].x) * (start_pos.x - way[i].x) +
					(start_pos.y - way[i].y) * (start_pos.y - way[i].y))
		
		start_pos = way[i]
	
	return dist
