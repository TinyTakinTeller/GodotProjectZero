class_name WorldScreen
extends MarginContainer

const TAB_DATA_ID: String = "world"

@export var progress_button_scene: PackedScene

var grid_containers: Array[GridContainer] = []
var is_soul: bool = false

@onready var h_box_container: HBoxContainer = %HBoxContainer
@onready var all_button: Button = %AllButton
@onready var experience_margin_container: ExperienceTracker = %ExperienceMarginContainer
@onready var npc_dialog: NpcDialog = %NpcDialog
@onready var padding_margin_container_1: MarginContainer = %PaddingMarginContainer1
@onready var padding_margin_container_2: MarginContainer = %PaddingMarginContainer2
@onready var grid_container_2: GridContainer = %GridContainer2
@onready var all_button_margin_container: MarginContainer = %AllButtonMarginContainer

###############
## overrides ##
###############


func _ready() -> void:
	_initialize()
	_refresh_labels()
	_connect_signals()
	_load_from_save_file()
	_on_display_language_updated()


#############
## helpers ##
#############


func _initialize() -> void:
	for node: Node in h_box_container.get_children():
		if is_instance_of(node, GridContainer):
			grid_containers.append(node as GridContainer)


func _refresh_labels() -> void:
	all_button.text = Locale.get_ui_label("harvest_forest")


func _load_from_save_file() -> void:
	_clear_items()
	for resource_generator_id: String in SaveFile.resource_generator_unlocks:
		_load_progress_button(resource_generator_id)

	var has_magician: bool = SaveFile.substances.get("the_magician", 0) > 0
	all_button.visible = has_magician


func _load_progress_button(resource_generator_id: String) -> void:
	var resource_generator: ResourceGenerator = Resources.resource_generators[resource_generator_id]
	_add_progress_button(resource_generator)


func _add_progress_button(resource_generator: ResourceGenerator) -> ProgressButton:
	var progress_button_item: ProgressButton = progress_button_scene.instantiate() as ProgressButton
	progress_button_item.set_resource_generator(resource_generator)
	NodeUtils.add_child_sorted(
		progress_button_item, grid_containers[resource_generator.column], ProgressButton.before_than
	)
	progress_button_item.display_resource_generator()
	return progress_button_item


func _clear_items() -> void:
	for grid_container: GridContainer in grid_containers:
		NodeUtils.clear_children_of(grid_container, ProgressButton)


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.tab_changed.connect(_on_tab_changed)
	SignalBus.progress_button_unlocked.connect(_on_progress_button_unlocked)
	all_button.button_down.connect(_on_all_button_down)
	all_button.button_up.connect(_on_all_button_up)
	all_button.mouse_entered.connect(_on_all_button_hover)
	SignalBus.progress_button_cooldown_end.connect(_on_progress_button_cooldown_end)
	SignalBus.substance_updated.connect(_on_substance_updated)
	SignalBus.soul.connect(_on_soul)
	SignalBus.display_language_updated.connect(_on_display_language_updated)


func _on_tab_changed(tab_data: TabData) -> void:
	if tab_data.id == TAB_DATA_ID:
		visible = true
	else:
		visible = false


func _on_progress_button_unlocked(resource_generator: ResourceGenerator) -> void:
	var progress_button_item: ProgressButton = _add_progress_button(resource_generator)
	progress_button_item.start_unlock_animation()


func _on_all_button_down() -> void:
	_on_all_button_hover()


func _on_all_button_up() -> void:
	all_button.disabled = true
	all_button.release_focus()
	for order: int in range(10):
		SignalBus.harvest_forest.emit(order)

	Audio.play_sfx_id("generic_click")


func _on_all_button_hover() -> void:
	SignalBus.info_hover.emit(
		Locale.get_ui_label("harvest_forest_title"), Locale.get_ui_label("harvest_forest_info")
	)


func _on_progress_button_cooldown_end(_resource_generator: ResourceGenerator) -> void:
	if not is_soul:
		all_button.disabled = false
		all_button.release_focus()


func _on_substance_updated(id: String, total_amount: int, _source_id: String) -> void:
	if id == "the_magician" and total_amount > 0:
		all_button.visible = true


func _on_soul() -> void:
	if Game.PARAMS["soul_disabled"]:
		return
	is_soul = true

	all_button.modulate = ColorSwatches.PURPLE
	all_button.disabled = true

	experience_margin_container.experience_label.modulate = ColorSwatches.PURPLE


func _on_display_language_updated() -> void:
	_refresh_labels()
	match TranslationServer.get_locale():
		"en":
			_set_padding_margin_left(8)
			all_button.reparent(all_button_margin_container)
		"fr":
			_set_padding_margin_left(0)
			all_button.reparent(grid_container_2)
		"zh":
			_set_padding_margin_left(32)
			all_button.reparent(all_button_margin_container)
		_:
			_set_padding_margin_left(8)
			all_button.reparent(all_button_margin_container)


func _set_padding_margin_left(margin_value: int) -> void:
	for node: Control in [padding_margin_container_1, padding_margin_container_2]:
		node.add_theme_constant_override("margin_left", margin_value)
