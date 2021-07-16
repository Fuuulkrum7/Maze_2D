extends KinematicBody2D

export var max_speed = 1
export var acceleration = 1

var current_speed = 0
var speed = Vector2()
var can_jump = true


func _ready():
	Global._Player = self


func _physics_process(delta):
	var velocity = Vector2()
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	if Input.is_action_pressed("ui_jump") and can_jump:
		set_collision_layer(2)
		set_collision_mask(2)
		can_jump = false
		$Jump.start()
		
	if velocity.length() > 0:
		velocity = velocity.normalized()
		speed += acceleration * velocity
		speed.x = clamp(speed.x, -max_speed, max_speed)
		speed.y = clamp(speed.y, -max_speed, max_speed)
	
	else:
		if abs(speed.x) > 20:
			speed.x -= acceleration * (speed.x / abs(speed.x))
		else:
			speed.x = 0
		
		if abs(speed.y) > 20:
			speed.y -= acceleration * (speed.y / abs(speed.y))
		else:
			speed.y = 0
	
	if is_on_floor() or is_on_ceiling():
		speed.y = 0
	if is_on_wall():
		speed.x = 0
		
	move_and_slide(speed, Vector2.UP)


func _On_Rest_timeout():
	can_jump = true


func _On_Jump_timeout():
	set_collision_layer(1)
	set_collision_mask(1)
	$Rest.start()
	Global._Camera.get_child(0).Show_Timer()
