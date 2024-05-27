extends Node

###############
## overrides ##
###############


func _ready() -> void:
	_connect_signals()


##############
## handlers ##
##############


func _handle_add(worker_role: WorkerRole) -> void:
	var id: String = worker_role.id
	if SaveFile.workers.get(Game.WORKER_RESOURCE_ID, 0) == 0:
		return
	SignalBus.worker_allocated.emit(id, 1, self.name)


func _handle_del(worker_role: WorkerRole) -> void:
	var id: String = worker_role.id
	if SaveFile.workers.get(id, 0) == 0:
		return
	SignalBus.worker_allocated.emit(id, -1, self.name)


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
