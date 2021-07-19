extends Sprite


var direction = Vector2()
var left_img = preload("res://Sprites/Ghost0.png")
var right_img = preload("res://Sprites/Ghost1.png")


func Change_Texture(dir):
	if dir.x <= 0:
		texture = left_img
	else:
		texture = right_img


func New_Dir():
	randomize()
	var dir = Vector2(randi() % 2 + 1, 
					  randi() % 2 + 1)
	
	dir.x /= -2 if randi() % 2 else 2
	dir.y /= -2 if randi() % 2 else 2
	
	Change_Texture(dir)
	
	return dir


func _ready():
	direction = New_Dir()


func _physics_process(delta):
	var screen = get_viewport().size
	
	if position.x > 0 and position.x < screen.x * 0.9:
		position.x += direction.x
	else:
		direction.x *= -1
		position.x += direction.x
		
		Change_Texture(direction)
	
	if position.y > 0 and position.y < screen.y * 0.9:
		position.y += direction.y
	else:
		direction.y *= -1
		position.y += direction.y


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			var pos = event.position
			pos = Vector2(int((pos.x) / 128), int((pos.y) / 128))
			
			var ghost_pos = Vector2(int(position.x / 128), int(position.y / 128))
			
			if ghost_pos == pos:
				direction = New_Dir()
