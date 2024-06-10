extends Resource
class_name TabData

@export var id: String

var level: int = 0
var index: int = -1


func get_title() -> String:
	return Locale.get_tab_data_titles(id)[level]


func get_index() -> int:
	return index
