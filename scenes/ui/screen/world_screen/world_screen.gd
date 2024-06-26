extends MarginContainer

const TAB_DATA_ID: String = "world"

@onready var h_box_container: HBoxContainer = %HBoxContainer

@export var progress_button_scene: PackedScene

var grid_containers: Array[GridContainer] = []

###############
## overrides ##
###############


func _ready() -> void:
	_initialize()
	_load_from_save_file()
	_connect_signals()


#############
## helpers ##
#############


func _initialize() -> void:
	for node: Node in h_box_container.get_children():
		if is_instance_of(node, GridContainer):
			grid_containers.append(node as GridContainer)


func _load_from_save_file() -> void:
	_clear_items()
	for resource_generator_id: String in SaveFile.resource_generator_unlocks:
		_load_progress_button(resource_generator_id)


func _load_progress_button(resource_generator_id: String) -> void:
	var resource_generator: ResourceGenerator = Resources.resource_generators[resource_generator_id]
	_add_progress_button(resource_generator)


func _add_progress_button(resource_generator: ResourceGenerator) -> ProgressButton:
	var progress_button_item: ProgressButton = progress_button_scene.instantiate() as ProgressButton
	progress_button_item.set_resource_generator(resource_generator)
	if resource_generator.sfx_generate:
		progress_button_item.sfx_button_down = resource_generator.sfx_generate
	if resource_generator.sfx_yield:
		progress_button_item.sfx_button_success = resource_generator.sfx_yield
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


func _on_tab_changed(tab_data: TabData) -> void:
	if tab_data.id == TAB_DATA_ID:
		visible = true
	else:
		visible = false


func _on_progress_button_unlocked(resource_generator: ResourceGenerator) -> void:
	var progress_button_item: ProgressButton = _add_progress_button(resource_generator)
	progress_button_item.start_unlock_animation()
