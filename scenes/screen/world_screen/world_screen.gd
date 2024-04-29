extends MarginContainer

@onready var grid_container: GridContainer = %GridContainer

@export var progress_button_scene: PackedScene


func _ready() -> void:
	_clear_items()
	add_progress_button("common")
	add_progress_button("rare")
	add_progress_button("worker")


func add_progress_button(id: String) -> void:
	var resource_generator: ResourceGenerator = Resources.resource_generators[id]
	var progress_button_item: ProgressButton = _add_item()
	progress_button_item.set_resource_generator(resource_generator)


func _add_item() -> ProgressButton:
	var progress_button_item: ProgressButton = progress_button_scene.instantiate() as ProgressButton
	grid_container.add_child(progress_button_item)
	return progress_button_item


func _clear_items() -> void:
	NodeUtils.clear_children_of(grid_container, ProgressButton)
