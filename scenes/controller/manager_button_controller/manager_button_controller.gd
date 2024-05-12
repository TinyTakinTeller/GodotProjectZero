extends Node


func _ready() -> void:
	SignalBus.manager_button_add.connect(_on_manager_button_add)
	SignalBus.manager_button_del.connect(_on_manager_button_del)


func _get_workers() -> int:
	return SaveFile.workers.get(Game.WORKER_RESOURCE_ID, 0)


func _handle_add(worker_role: WorkerRole) -> void:
	var id: String = worker_role.id
	if _get_workers() == 0:
		return
	SignalBus.worker_allocated.emit(id, 1)


func _handle_del(worker_role: WorkerRole) -> void:
	var id: String = worker_role.id
	if SaveFile.workers.get(id, 0) == 0:
		return
	SignalBus.worker_allocated.emit(id, -1)


func _on_manager_button_add(worker_role: WorkerRole) -> void:
	_handle_add(worker_role)


func _on_manager_button_del(worker_role: WorkerRole) -> void:
	_handle_del(worker_role)
