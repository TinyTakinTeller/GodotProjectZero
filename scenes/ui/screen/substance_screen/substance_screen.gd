extends MarginContainer

const TAB_DATA_ID: String = "substance"
const CATEGORIES: Array[String] = ["charm", "shadow", "spirit", "essence"]
const COLOR: Dictionary = {
	"charm": ColorSwatches.YELLOW,
	"shadow": ColorSwatches.BLUE,
	"spirit": ColorSwatches.GREEN,
	"essence": ColorSwatches.RED
}

@export var substance_category_scene: PackedScene

var substance_categories: Dictionary = {}

@onready var categories_v_box_container: VBoxContainer = %CategoriesVBoxContainer

###############
## overrides ##
###############


func _ready() -> void:
	_initialize()
	_connect_signals()
	_load_from_save_file()


#############
## helpers ##
#############


func _initialize() -> void:
	_clear_items()
	for category_id: String in CATEGORIES:
		_add_substance_category(category_id)


func _update_substance(substance_data_id: String) -> void:
	var substance_data: SubstanceData = Resources.substance_datas[substance_data_id]
	var category_id: String = substance_data.get_category_id()
	var substance_category: SubstanceCategory = substance_categories[category_id]
	var substance_item: SubstanceItem = substance_category.update_substance_item(substance_data)
	if substance_item.visible:
		substance_category.visible = true
	# edge case: hide charm category until first soulstone
	if category_id == "charm" and SaveFile.resources.get("soulstone", 0) == 0:
		substance_category.visible = false
	_update_substance_category(substance_category)


func _load_from_save_file() -> void:
	for substance_data_id: String in Resources.substance_datas:
		_update_substance(substance_data_id)


func _add_substance_category(category_id: String) -> void:
	var substance_category: SubstanceCategory = (
		substance_category_scene.instantiate() as SubstanceCategory
	)

	var count: int = SaveFile.get_substance_count_by_category(category_id)
	var title_label: String = StringUtils.humanify_string(category_id)
	var count_label: String = "x" + NumberUtils.format_number_scientific(count)
	var effect_label: String = _get_category_effect_label(category_id)

	substance_category.set_data(
		category_id, title_label, count_label, effect_label, COLOR[category_id]
	)
	NodeUtils.add_child(substance_category, categories_v_box_container)
	substance_category.display_data()
	substance_categories[category_id] = substance_category
	substance_category.visible = false


func _update_substance_category(substance_category: SubstanceCategory) -> void:
	var category_id: String = substance_category.get_id()

	var count: int = SaveFile.get_substance_count_by_category(category_id)
	var title_label: String = StringUtils.humanify_string(category_id)
	var count_label: String = _get_category_count_label(category_id, count)
	var effect_label: String = _get_category_effect_label(category_id)

	substance_category.update_data(title_label, count_label, effect_label, COLOR[category_id])


func _clear_items() -> void:
	NodeUtils.clear_children_of(categories_v_box_container, SubstanceCategory)


func _get_category_count_label(category_id: String, count: int) -> String:
	var count_label: String = NumberUtils.format_number(count)

	if category_id == "charm":
		var max_count: int = 0
		for substance_id: String in Resources.substance_datas:
			var substance_data: SubstanceData = Resources.substance_datas[substance_id]
			if substance_data.get_category_id() == "charm" and substance_data.is_unlocked():
				max_count += 1

		return count_label + "/" + str(max_count)

	return "x" + count_label


func _get_category_effect_label(category_id: String) -> String:
	var count: int = SaveFile.get_substance_count_by_category(category_id)

	if category_id == "shadow":
		var percent: int = SaveFile.get_shadow_percent()
		if percent >= 0:
			var percent_label: String = NumberUtils.format_number(percent)
			return "+" + percent_label + "% " + Locale.get_ui_label("shadow_effect")

	if category_id == "spirit":
		var ratio: int = Game.PARAMS["spirit_bonus"]
		var percent: int = (100 * count) / ratio
		if percent > 0:
			var percent_label: String = NumberUtils.format_number(percent)
			return "+" + percent_label + "% " + Locale.get_ui_label("spirit_effect")

	if category_id == "essence":
		var ratio: int = Game.PARAMS["essence_bonus"]
		var percent: int = (100 * count) / ratio
		if percent > 0:
			var percent_label: String = NumberUtils.format_number(percent)
			return "+" + percent_label + "% " + Locale.get_ui_label("essence_effect")

	return ""


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.tab_changed.connect(_on_tab_changed)
	SignalBus.substance_updated.connect(_on_substance_updated)


func _on_tab_changed(tab_data: TabData) -> void:
	if tab_data.id == TAB_DATA_ID:
		visible = true
	else:
		visible = false


func _on_substance_updated(id: String, _total_amount: int, _source_id: String) -> void:
	_update_substance(id)
