extends Node

###############
## overrides ##
###############


func _ready() -> void:
	_connect_signals()


##############
## handlers ##
##############


func _handle_on_progress_button_unlock(resource_generator: ResourceGenerator) -> void:
	var resource_generator_id: String = resource_generator.id
	SaveFile.resource_generator_unlocks.append(resource_generator_id)
	SignalBus.progress_button_unlocked.emit(resource_generator)


func _handle_on_manager_button_unlock(worker_role: WorkerRole) -> void:
	var worker_role_id: String = worker_role.id
	SaveFile.worker_role_unlocks.append(worker_role_id)
	SignalBus.manager_button_unlocked.emit(worker_role)


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.progress_button_unlock.connect(_on_progress_button_unlock)
	SignalBus.manager_button_unlock.connect(_on_manager_button_unlock)


func _on_progress_button_unlock(resource_generator: ResourceGenerator) -> void:
	_handle_on_progress_button_unlock(resource_generator)


func _on_manager_button_unlock(worker_role: WorkerRole) -> void:
	_handle_on_manager_button_unlock(worker_role)
