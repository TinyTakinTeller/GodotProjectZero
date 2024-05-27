extends Node
class_name WorkerManager

###############
## overrides ##
###############


func _ready() -> void:
	_connect_signals()


##############
## handlers ##
##############


func _handle_on_worker_allocated(id: String, amount: int) -> void:
	var wr_id: String = Game.WORKER_RESOURCE_ID
	_handle_on_worker_generated(wr_id, -amount)
	_handle_on_worker_generated(id, amount)


func _handle_on_worker_generated(id: String, amount: int) -> void:
	SaveFile.workers[id] = SaveFile.workers.get(id, 0) + amount
	SignalBus.worker_updated.emit(id, SaveFile.workers[id], amount)


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.worker_allocated.connect(_on_worker_allocated)
	SignalBus.worker_generated.connect(_on_worker_generated)


func _on_worker_allocated(id: String, amount: int, _source: String) -> void:
	_handle_on_worker_allocated(id, amount)


func _on_worker_generated(id: String, amount: int, _source: String) -> void:
	_handle_on_worker_generated(id, amount)
