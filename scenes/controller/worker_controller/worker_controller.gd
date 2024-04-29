extends Node
class_name WorkerController

@onready var timer: Timer = $Timer

const CYCLE_SECONDS: int = Game.params["cycle_seconds"]


func _ready() -> void:
	timer.wait_time = CYCLE_SECONDS
	timer.start()
	timer.timeout.connect(_on_timeout)


func get_cycle_time_left() -> float:
	return timer.time_left


func _on_timeout() -> void:
	var efficiencies: Dictionary = {}
	for id: String in SaveFile.workers.keys():
		var worker_count: int = SaveFile.workers[id]
		var consumes: Dictionary = Resources.worker_roles[id].get_consume()
		var produces: Dictionary = Resources.worker_roles[id].get_produce()
		var efficiency: int = WorkerController._get_efficiency(
			worker_count, consumes, SaveFile.resources
		)
		if efficiency == 0:
			continue
		_execute(-efficiency, consumes, efficiencies)
		_execute(efficiency, produces, efficiencies)
	SignalBus.worker_efficiency_updated.emit(efficiencies)

	# TODO: handle this in EventController
	if efficiencies.size() >= 3 and efficiencies.values().all(func(e: int) -> bool: return e > 0):
		SignalBus.event_triggered.emit("chapter", {})


func _execute(efficiency: int, target_resources: Dictionary, efficiencies: Dictionary) -> void:
	for resource_id: String in target_resources.keys():
		var base_amount: int = target_resources[resource_id]
		var total_amount: int = efficiency * base_amount
		SaveFile.resources[resource_id] += total_amount
		SignalBus.resource_updated.emit(resource_id, SaveFile.resources[resource_id], total_amount)
		efficiencies[resource_id] = efficiencies.get(resource_id, 0) + total_amount


static func _get_efficiency(worker_count: int, consumes: Dictionary, resources: Dictionary) -> int:
	var max_efficiency: int = worker_count
	for consume_id: String in consumes.keys():
		var consume_amount: int = consumes[consume_id]
		var resource_amount: int = resources.get(consume_id, 0)
		var efficiency: int = min(resource_amount / consume_amount, worker_count)
		max_efficiency = min(efficiency, max_efficiency)
	return max_efficiency
