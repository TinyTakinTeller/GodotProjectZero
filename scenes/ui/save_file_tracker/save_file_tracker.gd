extends MarginContainer
class_name SaveFileTracker

const DEFAULT_SAVE_FILE_NAME: String = "unnamed"

signal load_save_file(save_file_name: String)
signal delete_save_file(save_file_name: String)
signal new_save_file(save_file_name: String)
signal new_input_set(save_file_name: String, new_text: String, old_text: String)

@onready var save_item_v_box_container: VBoxContainer = %SaveItemVBoxContainer

@export var save_file_item_scene: PackedScene

###############
## overrides ##
###############


func _ready() -> void:
	_clear_items()
	_load_save_files()
	owner.ready.connect(_on_ready)


###########
## setup ##
###########


func get_last_played_save_file_name() -> String:
	if save_item_v_box_container.get_children().size() < 2:
		return ""
	var save_file_item: SaveFileItem = save_item_v_box_container.get_child(1)
	var save_file_name: String = save_file_item.get_save_file_name()
	return save_file_name


#############
## helpers ##
#############


func _load_save_files() -> void:
	_add_item({}, DEFAULT_SAVE_FILE_NAME, true)
	var save_datas: Dictionary = SaveFile.SAVE_DATAS
	for save_file_name: String in save_datas:
		var save_data: Dictionary = save_datas[save_file_name]
		var metadata: Dictionary = save_data.get("metadata", {})
		_add_item(metadata, save_file_name, false)


func _add_item(metadata: Dictionary, save_file_name: String, new: bool) -> SaveFileItem:
	var save_file_item: SaveFileItem = save_file_item_scene.instantiate() as SaveFileItem
	save_file_item.set_data(metadata, save_file_name, new)
	NodeUtils.add_child_sorted(save_file_item, save_item_v_box_container, SaveFileItem.after_than)
	save_file_item.display_sections(metadata)
	_connect_item_signals(save_file_item)
	return save_file_item


func _clear_items() -> void:
	NodeUtils.clear_children_of(save_item_v_box_container, SaveFileItem)


#############
## signals ##
#############


func _connect_item_signals(save_file_item: SaveFileItem) -> void:
	save_file_item.load_button_click.connect(_on_load_button_click)
	save_file_item.delete_button_click.connect(_on_delete_button_click)
	save_file_item.new_button_click.connect(_on_new_button_click)
	save_file_item.new_input_set.connect(_on_new_input_set)


func _on_ready() -> void:
	if SaveFile.SAVE_DATAS.is_empty():
		new_save_file.emit(DEFAULT_SAVE_FILE_NAME)


func _on_load_button_click(save_file_name: String) -> void:
	load_save_file.emit(save_file_name)


func _on_new_button_click(save_file_name: String) -> void:
	new_save_file.emit(save_file_name)


func _on_delete_button_click(save_file_name: String) -> void:
	delete_save_file.emit(save_file_name)


func _on_new_input_set(save_file_name: String, new_text: String, old_text: String) -> void:
	new_input_set.emit(save_file_name, new_text, old_text)
