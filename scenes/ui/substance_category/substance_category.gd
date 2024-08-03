class_name SubstanceCategory
extends MarginContainer

@export var substance_item_scene: PackedScene

var _id: String = ""
var _title: String = "?"
var _count: String = ""
var _effect: String = ""
var _color: Color = Color.WHITE

@onready var title_label: Label = %TitleLabel
@onready var count_label: Label = %CountLabel
@onready var effect_label: Label = %EffectLabel
@onready var screen_h_box_container: GridContainer = %ScreenHBoxContainer

###############
## overrides ##
###############


func _ready() -> void:
	_initialize()


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


func _initialize() -> void:
	_clear_items()


func _clear_items() -> void:
	NodeUtils.clear_children_of(screen_h_box_container, SubstanceItem)
