class_name SubstanceCategory
extends MarginContainer

@export var substance_item_scene: PackedScene

var _id: String = ""
var _title: String = "?"
var _count: String = ""
var _effect: String = ""
var _color: Color = Color.WHITE
var _toggle: bool = true

@onready var title_label: Label = %TitleLabel
@onready var count_label: Label = %CountLabel
@onready var effect_label: Label = %EffectLabel
@onready var screen_h_box_container: GridContainer = %ScreenHBoxContainer
@onready var toggle_button: Button = %ToggleButton

###############
## overrides ##
###############


func _ready() -> void:
	_initialize()
	_connect_signals()
	_load_from_save_file()


#############
## methods ##
#############


func get_id() -> String:
	return _id


func update_data(
	title: String, count: String = "", effect: String = "", color: Color = Color.WHITE
) -> void:
	set_data(_id, title, count, effect, color)
	display_data()


func set_data(
	id: String, title: String, count: String = "", effect: String = "", color: Color = Color.WHITE
) -> void:
	_id = id
	_title = title
	_count = count
	_effect = effect
	_color = color


func display_data() -> void:
	title_label.text = _title
	count_label.text = _count
	effect_label.text = _effect
	count_label.modulate = _color
	effect_label.modulate = _color


func add_substance_item(substance_data: SubstanceData) -> SubstanceItem:
	var substance_item: SubstanceItem = substance_item_scene.instantiate() as SubstanceItem
	substance_item.set_data(substance_data)
	NodeUtils.add_child_sorted(substance_item, screen_h_box_container, SubstanceItem.before_than)
	substance_item.display_data()
	return substance_item


func update_substance_item(substance_data: SubstanceData) -> SubstanceItem:
	for substance_item: SubstanceItem in screen_h_box_container.get_children():
		if substance_item.get_id() == substance_data.get_id():
			substance_item.refresh_count()
			substance_item.play_unlock_animation()
			return substance_item
	var new_substance_item: SubstanceItem = add_substance_item(substance_data)
	return new_substance_item


#############
## helpers ##
#############


func _load_from_save_file() -> void:
	var settings_id: String = "toggle_category_" + _id
	_toggle = SaveFile.settings.get(settings_id, true)
	_toggle_event()


func _toggle_event() -> void:
	screen_h_box_container.visible = _toggle
	if _toggle:
		toggle_button.text = "-"
	else:
		toggle_button.text = "+"


func _initialize() -> void:
	_clear_items()


func _clear_items() -> void:
	NodeUtils.clear_children_of(screen_h_box_container, SubstanceItem)


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.resource_updated.connect(_on_resource_updated)
	toggle_button.button_up.connect(_on_toggle_button_up)


# edge case: hide charm category until first soulstone
func _on_resource_updated(id: String, total: int, _amount: int, _source_id: String) -> void:
	if get_id() == "charm" and id == "soulstone" and total > 0:
		self.visible = true


func _on_toggle_button_up() -> void:
	toggle_button.release_focus()
	_toggle = not _toggle
	var settings_id: String = "toggle_category_" + _id
	SaveFile.settings[settings_id] = _toggle
	_toggle_event()

	Audio.play_sfx_id("generic_click")
