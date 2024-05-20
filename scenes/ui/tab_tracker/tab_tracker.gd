extends MarginContainer
class_name TabTracker

@onready var h_box_container: HBoxContainer = %HBoxContainer

@export var tab_item_scene: PackedScene

var tab_selected: int = -1
var tab_count: int = 0
var tabs: Dictionary = {}

###############
## overrides ##
###############


func _ready() -> void:
	_load_from_save_file()
	SignalBus.tab_unlocked.connect(_on_tab_unlocked)
	SignalBus.tab_leveled_up.connect(_on_tab_leveled_up)
	SignalBus.progress_button_unlocked.connect(_on_progress_button_unlocked)
	SignalBus.manager_button_unlocked.connect(_on_manager_button_unlocked)


#############
## helpers ##
#############


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
	var tab_tracker_item: TabTrackerItem = tabs.get(tab_data.index, null)
	if tab_tracker_item != null:
		tab_tracker_item.refresh_title()


func _add_tab_tracker_item(tab_data: TabData) -> TabTrackerItem:
	var tab_tracker_item: TabTrackerItem = _add_item()
	tab_tracker_item.set_tab_data(tab_data)
	tab_tracker_item.click.connect(_on_tab_clicked)
	tab_data.index = tab_count - 1
	return tab_tracker_item


func _add_item() -> TabTrackerItem:
	var tab_tracker_item: TabTrackerItem = tab_item_scene.instantiate() as TabTrackerItem
	h_box_container.add_child(tab_tracker_item)
	tab_count += 1
	tabs[tab_count - 1] = tab_tracker_item
	return tab_tracker_item


func _clear_items() -> void:
	tab_count = 0
	tabs = {}
	NodeUtils.clear_children(h_box_container)


func change_tab(index: int) -> void:
	var tab_tracker_item: TabTrackerItem = tabs.get(index, null)
	if tab_tracker_item != null:
		_handle_tab_clicked(tab_tracker_item._tab_data)


##############
## handlers ##
##############


func _handle_tab_clicked(tab_data: TabData) -> void:
	for tab_tracker_item: TabTrackerItem in h_box_container.get_children():
		if tab_tracker_item._tab_data.id == tab_data.id:
			tab_tracker_item.button.disabled = true
		else:
			tab_tracker_item.button.disabled = false
	tab_selected = tab_data.index
	SignalBus.tab_changed.emit(tab_data)


func _handle_on_tab_unlocked(tab_data: TabData) -> void:
	var tab_tracker_item: TabTrackerItem = _add_tab_tracker_item(tab_data)
	tab_tracker_item.start_unlock_animation()


func _handle_on_unlocked(tab_index: int) -> void:
	if tab_selected == tab_index:
		return
	var tab_tracker_item: TabTrackerItem = tabs.get(tab_index, null)
	if tab_tracker_item != null:
		tab_tracker_item.start_unlock_animation()


#############
## signals ##
#############


func _on_tab_clicked(tab_data: TabData) -> void:
	_handle_tab_clicked(tab_data)


func _on_tab_unlocked(tab_data: TabData) -> void:
	_handle_on_tab_unlocked(tab_data)


func _on_tab_leveled_up(tab_data: TabData) -> void:
	_update_tab_tracker_item(tab_data)


func _on_progress_button_unlocked(_resource_generator: ResourceGenerator) -> void:
	_handle_on_unlocked(0)


func _on_manager_button_unlocked(_worker_role: WorkerRole) -> void:
	_handle_on_unlocked(1)
