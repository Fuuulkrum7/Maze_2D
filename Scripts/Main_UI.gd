extends Control

var default_time = 0
var current_time = 0
signal restart


func _ready():
	var timer = Global._Player.get_child(2)
	default_time = int(timer.wait_time)


func _process(delta):
	if Input.is_action_just_pressed("ui_pause"):
		Continue()


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


func Continue():
	$Continue.visible = not $Continue.visible
	get_tree().paused = not get_tree().paused
	$Restart.visible = not $Restart.visible
	$Exit.visible = not $Exit.visible
	$Key.visible = not $Key.visible


func _on_Restart_pressed():
	Continue()
	$Continue.visible = false
	emit_signal("restart")


func _on_Exit_pressed():
	Global.goto_scene("res://Scenes/Menu.tscn")


func Finish():
	Continue()
	$Continue.visible = false
