extends Camera2D

export(float) var A = 0		# ускорение, с которым двигается камера

var pressed = false			# проверка на то, нажата ли кнопка


func _ready():
	Global._Camera = self
	position = Global._Player.position


func _physics_process(delta):
	var camera_move = Global._Player.position - position
	position += camera_move * delta * A


func _input(event):
	if event is InputEventMouseButton:
		"""
		if event.button_index == BUTTON_WHEEL_UP and event.pressed and zoom > Vector2(0.9, 0.9):
			zoom -= Vector2(0.05, 0.05)
		if event.button_index == BUTTON_WHEEL_DOWN and event.pressed and zoom < Vector2(1.9, 1.9):
			zoom += Vector2(0.05, 0.05)"""
		
		if event.button_index == BUTTON_LEFT:
			pressed = event.pressed
	
	if event is InputEventMouseMotion and pressed:
		position -= event.speed / 40

