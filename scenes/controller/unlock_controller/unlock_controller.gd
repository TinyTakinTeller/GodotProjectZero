extends Node


func _ready() -> void:
	SignalBus.resource_updated.connect(_on_resource_updated)
	SignalBus.worker_updated.connect(_on_worker_updated)


func _handle_resource_updated(observed_id: String, observed_total: int) -> void:
	_unlock_resource_generator_if("worker", observed_id == "common", observed_total >= 10)
	_unlock_tab_if("manager", observed_id == "worker", observed_total >= 1)
	_unlock_resource_generator_if("house", observed_id == "worker", observed_total >= 1)


func _handle_worker_updated(observed_id: String, observed_total: int) -> void:
	_unlock_manager_button_if("recruiter", observed_id == "explorer", observed_total >= 1)


func _unlock_resource_generator_if(unlock_id: String, event: bool, condition: bool) -> void:
	if event and !SaveFile.resource_generator_unlocks.has(unlock_id) and condition:
		var resource_generator: ResourceGenerator = Resources.resource_generators[unlock_id]
		SignalBus.progress_button_unlock.emit(resource_generator)


func _unlock_manager_button_if(unlock_id: String, event: bool, condition: bool) -> void:
	if event and !SaveFile.worker_role_unlocks.has(unlock_id) and condition:
		var worker_role: WorkerRole = Resources.worker_roles[unlock_id]
		SignalBus.manager_button_unlock.emit(worker_role)


func _unlock_tab_if(unlock_id: String, event: bool, condition: bool) -> void:
	if event and !SaveFile.tab_unlocks.has(unlock_id) and condition:
		var tab_data: TabData = Resources.tab_datas[unlock_id]
		SignalBus.tab_unlock.emit(tab_data)


func _on_resource_updated(id: String, total: int, _amount: int) -> void:
	_handle_resource_updated(id, total)


func _on_worker_updated(id: String, total: int, _amount: int) -> void:
	_handle_worker_updated(id, total)
