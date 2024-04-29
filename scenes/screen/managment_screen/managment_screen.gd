extends MarginContainer

@onready var grid_container: GridContainer = %GridContainer

@export var manager_button_scene: PackedScene


func _ready() -> void:
	_clear_items()
	add_manager_button("vanderer")
	add_manager_button("explorer")
	add_manager_button("recruiter")


func add_manager_button(id: String) -> void:
	var worker_role: WorkerRole = Resources.worker_roles[id]
	var manager_button_item: ManagerButton = _add_item()
	manager_button_item.set_worker_role(worker_role)


func _add_item() -> ManagerButton:
	var manager_button_item: ManagerButton = manager_button_scene.instantiate() as ManagerButton
	grid_container.add_child(manager_button_item)
	return manager_button_item


func _clear_items() -> void:
	NodeUtils.clear_children_of(grid_container, ManagerButton)
