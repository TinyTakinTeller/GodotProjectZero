extends Node
class_name WorkerManager

@export var managed_resource_id: String = "worker"


func _ready() -> void:
	SignalBus.manager_button_add.connect(_on_manager_button_add)
	SignalBus.manager_button_del.connect(_on_manager_button_del)


func _handle_add(worker_role: WorkerRole) -> void:
	var id: String = worker_role.id
	if _get_workers() == 0:
		return
	_add_worker(id, 1)


func _handle_del(worker_role: WorkerRole) -> void:
	var id: String = worker_role.id
	if SaveFile.workers.get(id, 0) == 0:
		return
	_add_worker(worker_role.id, -1)


func _get_workers() -> int:
	return SaveFile.resources.get(managed_resource_id, 0)


func _add_worker(id: String, amount: int) -> void:
	SaveFile.resources[managed_resource_id] -= amount
	SignalBus.resource_updated.emit(
		managed_resource_id, SaveFile.resources[managed_resource_id], -amount
	)

	SaveFile.workers[id] = SaveFile.workers.get(id, 0) + amount
	SignalBus.worker_updated.emit(id, SaveFile.workers[id], amount)


func _on_manager_button_add(worker_role: WorkerRole) -> void:
	_handle_add(worker_role)


func _on_manager_button_del(worker_role: WorkerRole) -> void:
	_handle_del(worker_role)
