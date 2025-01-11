class_name TabTracker extends MarginContainer

@export var tab_item_scene: PackedScene

var tab_selected_index: int = -1
var tab_selected_id: String = ""
var tab_count: int = 0
var tabs: Dictionary = {}

@onready var h_box_container: HBoxContainer = %HBoxContainer

###############
## overrides ##
###############


func _ready() -> void:
	_connect_signals()
	_load_from_save_file()


#############
## helpers ##
#############


func _load_from_save_file() -> void:
	_clear_items()
	for tab_data_id: String in SaveFile.tab_unlocks:
		_load_tab_tracker_item(tab_data_id)


func _load_tab_tracker_item(tab_data_id: String) -> void:
	var tab_data: TabData = Resources.tab_datas[tab_data_id]
	_add_tab_tracker_item(tab_data)


func _update_tab_tracker_item(tab_data: TabData) -> void:
	var tab_tracker_item: TabTrackerItem = tabs.get(tab_data.index, null)
	if tab_tracker_item != null:
		tab_tracker_item.refresh_title()


func _add_tab_tracker_item(tab_data: TabData) -> TabTrackerItem:
	var tab_tracker_item: TabTrackerItem = tab_item_scene.instantiate() as TabTrackerItem
	tab_tracker_item.set_tab_data(tab_data, self)
	tab_tracker_item.click.connect(_on_tab_clicked)
	NodeUtils.add_child_sorted(tab_tracker_item, h_box_container, TabTrackerItem.before_than)
	tab_tracker_item.refresh_title()
	tab_count += 1
	tabs[tab_count - 1] = tab_tracker_item
	tab_data.index = tab_count - 1
	return tab_tracker_item


func _add_item() -> TabTrackerItem:
	var tab_tracker_item: TabTrackerItem = tab_item_scene.instantiate() as TabTrackerItem
	NodeUtils.add_child_sorted(tab_tracker_item, h_box_container, TabTrackerItem.before_than)
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


func change_tab_shortcut(number: int) -> void:
	if number >= h_box_container.get_child_count():
		return
	var tab_tracker_item: TabTrackerItem = h_box_container.get_child(number)
	_handle_tab_clicked(tab_tracker_item._tab_data)


##############
## handlers ##
##############


func _handle_tab_clicked(tab_data: TabData) -> void:
	if tab_data == null:
		return
	for tab_tracker_item: TabTrackerItem in h_box_container.get_children():
		if tab_tracker_item._tab_data.id == tab_data.id:
			tab_tracker_item.button.disabled = true
		else:
			tab_tracker_item.button.disabled = false
	tab_selected_index = tab_data.index
	tab_selected_id = tab_data.id
	SignalBus.tab_changed.emit(tab_data)


func _handle_on_tab_unlocked(tab_data: TabData) -> void:
	var tab_tracker_item: TabTrackerItem = _add_tab_tracker_item(tab_data)
	tab_tracker_item.start_unlock_animation()


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.tab_clicked.connect(_on_tab_clicked)
	SignalBus.tab_unlocked.connect(_on_tab_unlocked)
	SignalBus.tab_leveled_up.connect(_on_tab_leveled_up)


func _on_tab_clicked(tab_data: TabData) -> void:
	_handle_tab_clicked(tab_data)


func _on_tab_unlocked(tab_data: TabData) -> void:
	_handle_on_tab_unlocked(tab_data)


func _on_tab_leveled_up(tab_data: TabData) -> void:
	_update_tab_tracker_item(tab_data)
