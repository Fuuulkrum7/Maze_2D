extends Control

var default_time = 0
var current_time = 0


func _ready():
	var timer = Global._Player.get_child(2)
	default_time = int(timer.wait_time)


func Show_Timer():
	current_time = default_time
	$Rest_Timer.visible = true
	$Rest_Timer.text = str(default_time)
	$One_Second.start()


func _on_One_Second_timeout():
	current_time -= 1
	if current_time > 0:
		$Rest_Timer.text = str(current_time)
		$One_Second.start()
	else:
		$Rest_Timer.visible = false
