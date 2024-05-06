extends Resource
class_name TabData

@export var id: String
@export var titles: Array

var level: int = 0
var index: int = -1


func get_title() -> String:
	return titles[level]


func get_index() -> int:
	return index
