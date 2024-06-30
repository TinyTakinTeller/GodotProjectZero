extends Resource
class_name TabData

@export var id: String
@export var sort_value: int = 0

var level: int = 0
var index: int = -1


func get_sort_value() -> int:
	return sort_value


func get_title() -> String:
	return Locale.get_tab_data_titles(id)[level]


func get_index() -> int:
	return index
