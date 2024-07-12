class_name SaveFileItem
extends MarginContainer

signal load_button_click(save_file_name: String)
signal delete_button_click(save_file_name: String)
signal new_button_click(save_file_name: String)
signal new_input_set(save_file_name: String, new_text: String, old_text: String)

const SECTION_1_WIDTH_PX: int = 180
const SECTION_2_WIDTH_PX: int = 140
const SECTION_3_WIDTH_PX: int = 170

@export var save_file_item_section_scene: PackedScene

var name_section: SaveFileItemSection

var _save_file_name: String
var _new: bool
var _sort_value: int
var _delete_counter: int = 0

@onready var load_button: Button = %LoadButton
@onready var delete_button: Button = %DeleteButton
@onready var new_button: Button = %NewButton
@onready var load_margin_container: MarginContainer = %LoadMarginContainer
@onready var delete_margin_container: MarginContainer = %DeleteMarginContainer
@onready var new_margin_container: MarginContainer = %NewMarginContainer
@onready var section_h_box_container: HBoxContainer = %SectionHBoxContainer

###############
## overrides ##
###############


func _ready() -> void:
	_initialize()
	_connect_signals()


###########
## setup ##
###########


func get_save_file_name() -> String:
	return _save_file_name


func set_data(metadata: Dictionary, save_file_name: String, new: bool) -> void:
	_save_file_name = save_file_name
	_new = new

	var now: Dictionary = Time.get_datetime_dict_from_system(true)
	var last_utc_time: Dictionary = metadata.get("last_utc_time", now)
	_sort_value = DateTimeUtils.datetime_to_int(last_utc_time)


func display_sections(metadata: Dictionary) -> void:
	var ui_name: String = Locale.get_ui_label("name")
	var ui_playtime: String = Locale.get_ui_label("playtime")
	var ui_last_played: String = Locale.get_ui_label("last_played")

	var metadata_name: String = metadata.get("save_file_name", _save_file_name)
	name_section = _add_section(ui_name, metadata_name, SECTION_1_WIDTH_PX, true)
	name_section.new_input_set.connect(_on_new_input_set)

	if _new:
		_add_section(ui_playtime, "---", SECTION_2_WIDTH_PX)
		_add_section(ui_last_played, "---", SECTION_3_WIDTH_PX)

	else:
		var seconds: int = int(metadata.get("total_autosave_seconds", str(0)))
		var playtime: String = DateTimeUtils.format_seconds(seconds)
		_add_section(ui_playtime, playtime, SECTION_2_WIDTH_PX)

		var now: Dictionary = Time.get_datetime_dict_from_system(true)
		var timezone: Dictionary = Time.get_time_zone_from_system()
		var last_utc_time: Dictionary = metadata.get("last_utc_time", now)
		var last_timezone: Dictionary = metadata.get("last_timezone", timezone)
		var last_time: Dictionary = DateTimeUtils.with_timezone(last_utc_time, last_timezone)
		var last_played: String = DateTimeUtils.format_datetime(last_time)
		_add_section(ui_last_played, last_played, SECTION_3_WIDTH_PX)

	_display_new(_new)


#############
## helpers ##
#############


func _initialize() -> void:
	_set_ui_labels()
	_clear_sections()
	_display_delete_counter()


func _set_ui_labels() -> void:
	var ui_load: String = Locale.get_ui_label("load")
	var ui_delete: String = Locale.get_ui_label("delete")
	var ui_new_game: String = Locale.get_ui_label("new_game")
	load_button.text = ui_load
	delete_button.text = ui_delete
	new_button.text = ui_new_game


func _add_section(
	title_text: String, value_text: String, width: int, input: bool = false
) -> SaveFileItemSection:
	var save_file_item_section: SaveFileItemSection = (
		save_file_item_section_scene.instantiate() as SaveFileItemSection
	)
	NodeUtils.add_child(save_file_item_section, section_h_box_container)
	save_file_item_section.set_labels(title_text, value_text, input)
	save_file_item_section.set_custom_minimum_size(Vector2(width, 0))
	return save_file_item_section


func _clear_sections() -> void:
	NodeUtils.clear_children_of(section_h_box_container, SaveFileItemSection)


func _display_new(new: bool) -> void:
	if new:
		load_margin_container.visible = false
		delete_margin_container.visible = false
		new_margin_container.visible = true
	else:
		load_margin_container.visible = true
		delete_margin_container.visible = true
		new_margin_container.visible = false


func _display_delete_counter() -> void:
	var ui_delete: String = Locale.get_ui_label("delete")
	if _delete_counter == 0:
		delete_button.text = ui_delete
	else:
		delete_button.text = "(" + str(Game.params["delete_counter"] + 1 - _delete_counter) + ")"


##############
## handlers ##
##############


func _handle_on_delete_button() -> void:
	if _delete_counter >= Game.params["delete_counter"]:
		delete_button_click.emit(_save_file_name)
		queue_free()
	else:
		_delete_counter += 1
		_display_delete_counter()
	delete_button.release_focus()


#############
## signals ##
#############


func _connect_signals() -> void:
	load_button.button_up.connect(_on_load_button)
	new_button.button_up.connect(_on_new_button)
	delete_button.button_up.connect(_on_delete_button)
	delete_button.mouse_exited.connect(_on_delete_reset)


func _on_load_button() -> void:
	load_button_click.emit(_save_file_name)


func _on_new_button() -> void:
	new_button_click.emit(name_section.get_input_text())


func _on_delete_button() -> void:
	_handle_on_delete_button()


func _on_delete_reset() -> void:
	_delete_counter = 0
	_display_delete_counter()


func _on_new_input_set(new_text: String, old_text: String) -> void:
	if !_new:
		new_input_set.emit(_save_file_name, new_text, old_text)


############
## static ##
############


static func before_than(a: SaveFileItem, b: SaveFileItem) -> bool:
	return a._sort_value < b._sort_value


static func after_than(a: SaveFileItem, b: SaveFileItem) -> bool:
	return !SaveFileItem.before_than(a, b)
