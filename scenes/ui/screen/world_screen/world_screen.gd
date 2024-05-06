extends MarginContainer

const TAB_DATA_ID: String = "world"

@onready var grid_container: GridContainer = %GridContainer

@export var progress_button_scene: PackedScene


func _ready() -> void:
	_load_from_save_file()
	SignalBus.tab_changed.connect(_on_tab_changed)
	SignalBus.progress_button_unlocked.connect(_on_progress_button_unlocked)


func _load_from_save_file() -> void:
	_clear_items()
	for resource_generator_id: String in SaveFile.resource_generator_unlocks:
		_load_progress_button(resource_generator_id)


func _load_progress_button(resource_generator_id: String) -> void:
	var resource_generator: ResourceGenerator = Resources.resource_generators[resource_generator_id]
	_add_progress_button(resource_generator)


func _add_progress_button(resource_generator: ResourceGenerator) -> ProgressButton:
	var progress_button_item: ProgressButton = _add_item()
	progress_button_item.set_resource_generator(resource_generator)
	return progress_button_item


func _add_item() -> ProgressButton:
	var progress_button_item: ProgressButton = progress_button_scene.instantiate() as ProgressButton
	grid_container.add_child(progress_button_item)
	return progress_button_item


func _clear_items() -> void:
	NodeUtils.clear_children_of(grid_container, ProgressButton)


func _on_tab_changed(tab_data: TabData) -> void:
	if tab_data.id == TAB_DATA_ID:
		visible = true
	else:
		visible = false


func _on_progress_button_unlocked(resource_generator: ResourceGenerator) -> void:
	var progress_button_item: ProgressButton = _add_progress_button(resource_generator)
	progress_button_item.start_unlock_animation()
