extends Node

var _Player
var _Camera
var _Spawn_pos
var current_scene = null

const _Finish = preload("res://Scenes/Finish.tscn")
const _Spawn = preload("res://Scenes/SpawnPoint.tscn")


func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)


func goto_scene(path):
	call_deferred("_deferred_goto_scene", path)


func _deferred_goto_scene(path):
	# It is now safe to remove the current scene
	current_scene.free()

	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instance()

	# Add it to the active scene, as child of root.
	get_tree().get_root().add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene() API.
	get_tree().set_current_scene(current_scene)


func choice(data):
	var lenght = len(data)
	var result = data[randi() % lenght]
	
	return result


func load_file(path):
	var file = File.new()
	file.open(path, File.READ)
	var content = file.get_as_text()
	file.close()
	return content


"""
TODO
Темный режим (?)
"""
