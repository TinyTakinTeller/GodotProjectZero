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
	var wid: String = Game.WORKER_RESOURCE_ID
	if id != wid:
		SaveFile.workers[wid] = (SaveFile.workers.get(wid, 0) - amount)
		SignalBus.worker_updated.emit(wid, SaveFile.workers[wid], amount)
	SaveFile.workers[id] = SaveFile.workers.get(id, 0) + amount
	SignalBus.worker_updated.emit(id, SaveFile.workers[id], amount)


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.worker_allocated.connect(_on_worker_allocated)


func _on_worker_allocated(id: String, amount: int) -> void:
	_handle_on_worker_allocated(id, amount)
