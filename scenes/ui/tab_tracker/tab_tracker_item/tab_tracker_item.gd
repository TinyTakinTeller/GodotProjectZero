extends Control
class_name TabTrackerItem

var _tab_data: TabData


func _ready() -> void:
	pass


func get_tab_data() -> TabData:
	return _tab_data


func set_tab_data(tab_data: TabData) -> void:
	_tab_data = tab_data
