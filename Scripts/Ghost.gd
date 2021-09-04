extends Area2D


export var speed = 2.5


var paused = false
var left = true
var left_img = preload("res://Sprites/Ghost0.png")
var right_img = preload("res://Sprites/Ghost1.png")


func _ready():
	connect("body_entered", get_parent(), "_On_enemy_entered")


func _physics_process(delta):
	var player_pos = Global._Player.position
	if player_pos.x < position.x and not left:
		$Sprite.texture = left_img
		left = true
	elif player_pos.x > position.x and left:
		$Sprite.texture = right_img
		left = false
	
	var delta_pos = player_pos - position
	var max_delta = max(abs(delta_pos.x), abs(delta_pos.y))
	
	if sqrt(delta_pos.x * delta_pos.x + delta_pos.y * delta_pos.y) < 800:
		delta_pos /= max_delta
		
		if not paused:
			position += delta_pos.normalized() * speed
