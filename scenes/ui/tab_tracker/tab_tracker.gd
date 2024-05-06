extends MarginContainer
class_name TabTracker

@onready var tab_container: TabContainer = %TabContainer

@export var tab_item_scene: PackedScene

var new_unlock_tween_index: Dictionary = {}


func _ready() -> void:
	_load_from_save_file()
	tab_container.tab_changed.connect(_on_tab_changed)
	SignalBus.tab_unlocked.connect(_on_tab_unlocked)
	SignalBus.tab_leveled_up.connect(_on_tab_leveled_up)


func _load_from_save_file() -> void:
	_clear_items()
	for tab_data_id: String in SaveFile.tab_unlocks:
		_load_tab_tracker_item(tab_data_id)


func _load_tab_tracker_item(tab_data_id: String) -> void:
	var tab_data: TabData = Resources.tab_datas[tab_data_id]
	tab_data.level = SaveFile.tab_levels.get(tab_data_id, 0)
	_add_tab_tracker_item(tab_data)


func _update_tab_tracker_item(tab_data: TabData) -> void:
	var tab_data_id: String = tab_data.id
	tab_data.level = SaveFile.tab_levels[tab_data_id]
	tab_container.set_tab_title(tab_data.get_index(), tab_data.get_title())


func _add_tab_tracker_item(tab_data: TabData) -> void:
	var tab_tracker_item: TabTrackerItem = _add_item()
	tab_tracker_item.set_tab_data(tab_data)
	var last_index: int = tab_container.get_tab_count() - 1
	tab_data.index = last_index
	tab_container.set_tab_title(tab_data.get_index(), tab_data.get_title())


func _add_item() -> TabTrackerItem:
	var tab_tracker_item: TabTrackerItem = tab_item_scene.instantiate() as TabTrackerItem
	tab_container.add_child(tab_tracker_item)
	return tab_tracker_item


func _clear_items() -> void:
	NodeUtils.clear_children(tab_container)


func _on_tab_changed(tab_index: int) -> void:
	var tab_tracker_item: TabTrackerItem = tab_container.get_tab_control(tab_index)
	var tab_data: TabData = tab_tracker_item.get_tab_data()
	SignalBus.tab_changed.emit(tab_data)


func _on_tab_unlocked(tab_data: TabData) -> void:
	_add_tab_tracker_item(tab_data)


func _on_tab_leveled_up(tab_data: TabData) -> void:
	_update_tab_tracker_item(tab_data)
