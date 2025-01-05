extends MarginContainer

const TAB_DATA_ID: String = "manager"

@export var manager_button_scene: PackedScene
@export var worker_controller: WorkerController

var grid_containers: Array[GridContainer] = []

@onready var h_box_container: HBoxContainer = %HBoxContainer
@onready var basic_progress_bar: BasicProgressBar = %BasicProgressBar

###############
## overrides ##
###############


func _process(_delta: float) -> void:
	if worker_controller != null:
		var percent: float = worker_controller.timer.time_left / SaveFile.get_cycle_seconds()
		basic_progress_bar.set_display(percent)


func _ready() -> void:
	_connect_signals()
	_reload()


#############
## helpers ##
#############


func _reload() -> void:
	_initialize()
	_load_from_save_file()


func _load_from_save_file() -> void:
	_clear_items()
	for worker_role_id: String in SaveFile.worker_role_unlocks:
		_load_manager_button(worker_role_id)


func _load_manager_button(worker_role_id: String) -> void:
	var worker_role: WorkerRole = Resources.worker_roles[worker_role_id]
	var worker_amount: int = SaveFile.workers.get(worker_role_id, 0)
	_add_manager_button(worker_role, worker_amount)


func _add_manager_button(worker_role: WorkerRole, amount: int) -> ManagerButton:
	var manager_button_item: ManagerButton = manager_button_scene.instantiate() as ManagerButton
	manager_button_item.set_worker_role(worker_role)
	NodeUtils.add_child_sorted(
		manager_button_item, grid_containers[worker_role.column], ManagerButton.before_than
	)
	manager_button_item.display_worker_role(amount)
	return manager_button_item


func _clear_items() -> void:
	for grid_container: GridContainer in grid_containers:
		NodeUtils.clear_children_of(grid_container, ManagerButton)


func _initialize() -> void:
	for node: Node in h_box_container.get_children():
		if is_instance_of(node, GridContainer):
			grid_containers.append(node as GridContainer)


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.tab_changed.connect(_on_tab_changed)
	SignalBus.manager_button_unlocked.connect(_on_manager_button_unlocked)
	SignalBus.worker_efficiency_updated.connect(_on_worker_efficiency_updated)
	SignalBus.display_language_updated.connect(_on_display_language_updated)


func _on_tab_changed(tab_data: TabData) -> void:
	if tab_data.id == TAB_DATA_ID:
		visible = true
	else:
		visible = false


func _on_manager_button_unlocked(worker_role: WorkerRole) -> void:
	var manager_button_item: ManagerButton = _add_manager_button(worker_role, 0)
	manager_button_item.start_unlock_animation()


func _on_worker_efficiency_updated(_efficiencies: Dictionary, generate: bool) -> void:
	if !is_visible_in_tree():
		return
	if generate:
		Audio.play_sfx_id("managment_screen_cycle")


func _on_display_language_updated() -> void:
	_reload()
