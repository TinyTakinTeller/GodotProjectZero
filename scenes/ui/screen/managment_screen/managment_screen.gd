extends MarginContainer

const TAB_DATA_ID: String = "manager"

@onready var grid_container: GridContainer = %GridContainer

@export var manager_button_scene: PackedScene


func _ready() -> void:
	_load_from_save_file()
	SignalBus.tab_changed.connect(_on_tab_changed)
	SignalBus.manager_button_unlocked.connect(_on_manager_button_unlocked)


func _load_from_save_file() -> void:
	_clear_items()
	for worker_role_id: String in SaveFile.worker_role_unlocks:
		_load_manager_button(worker_role_id)


func _load_manager_button(worker_role_id: String) -> void:
	var worker_role: WorkerRole = Resources.worker_roles[worker_role_id]
	var worker_amount: int = SaveFile.workers.get(worker_role_id, 0)
	_add_manager_button(worker_role, worker_amount)


func _add_manager_button(worker_role: WorkerRole, amount: int) -> ManagerButton:
	var manager_button_item: ManagerButton = _add_item()
	manager_button_item.set_worker_role(worker_role, amount)
	return manager_button_item


func _add_item() -> ManagerButton:
	var manager_button_item: ManagerButton = manager_button_scene.instantiate() as ManagerButton
	grid_container.add_child(manager_button_item)
	return manager_button_item


func _clear_items() -> void:
	NodeUtils.clear_children_of(grid_container, ManagerButton)


func _on_tab_changed(tab_data: TabData) -> void:
	if tab_data.id == TAB_DATA_ID:
		visible = true
	else:
		visible = false


func _on_manager_button_unlocked(worker_role: WorkerRole) -> void:
	var manager_button_item: ManagerButton = _add_manager_button(worker_role, 0)
	manager_button_item.start_unlock_animation()
