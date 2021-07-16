extends Node

var _Player
var _Camera
var _Spawn_pos

const _Finish = preload("res://Scenes/Finish.tscn")
const _Spawn = preload("res://Scenes/SpawnPoint.tscn")


func choice(data):
	var lenght = len(data)
	var result = data[randi() % lenght]
	
	return result

"""
TODO
UI
Темный режим (?)
Во вторую очередь:
Генерацию предметов по карте (допустим, всего три штуки)
В третью: мобов
"""
