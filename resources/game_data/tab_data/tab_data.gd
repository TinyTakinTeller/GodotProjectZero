class_name TabData
extends Resource

@export var id: String
@export var sort_value: int = 0

var index: int = -1


func get_sort_value() -> int:
	return sort_value


func get_title() -> String:
	var level: int = SaveFile.tab_levels.get(id, 0)
	var options: Array = Locale.get_tab_data_titles(id)
	if options.is_empty():
		return "?"
	return options[level]


func get_info() -> String:
	return Locale.get_ui_label("tab_info_" + id)


func get_index() -> int:
	return index
