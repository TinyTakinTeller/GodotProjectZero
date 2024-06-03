extends Node

###############
## overrides ##
###############


func _ready() -> void:
	_connect_signals()


#############
## helpers ##
#############


func _get_settings_population_scale(id: String) -> int:
	var workers: int = SaveFile.workers.get(id, 0)
	var amount: int = SaveFile.get_settings_population_scale()
	if amount < 0:
		amount = workers
	amount = min(amount, workers)
	return amount


##############
## handlers ##
##############


func _handle_add(worker_role: WorkerRole) -> void:
	var amount: int = _get_settings_population_scale(Game.WORKER_RESOURCE_ID)
	if amount == 0:
		return
	var id: String = worker_role.id
	SignalBus.worker_allocated.emit(id, amount, self.name)


func _handle_del(worker_role: WorkerRole) -> void:
	var id: String = worker_role.id
	var amount: int = _get_settings_population_scale(id)
	if amount == 0:
		return
	SignalBus.worker_allocated.emit(id, -amount, self.name)


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.manager_button_add.connect(_on_manager_button_add)
	SignalBus.manager_button_del.connect(_on_manager_button_del)


func _on_manager_button_add(worker_role: WorkerRole) -> void:
	_handle_add(worker_role)


func _on_manager_button_del(worker_role: WorkerRole) -> void:
	_handle_del(worker_role)
