extends Node
class_name WorkerController

const CYCLE_SECONDS: int = Game.params["cycle_seconds"]

@onready var timer: Timer = $Timer


func _ready() -> void:
	timer.wait_time = CYCLE_SECONDS
	timer.timeout.connect(_on_timeout)
	timer.start()


func get_cycle_time_left() -> float:
	return timer.time_left


func _on_timeout() -> void:
	var efficiencies: Dictionary = {}
	for worker_role_id: String in SaveFile.workers:
		var worker_count: int = SaveFile.workers[worker_role_id]
		var consumes: Dictionary = Resources.worker_roles[worker_role_id].get_consume()
		var produces: Dictionary = Resources.worker_roles[worker_role_id].get_produce()
		var efficiency: int = WorkerController._get_efficiency(
			worker_count, consumes, SaveFile.resources
		)
		if efficiency == 0:
			continue
		_execute(-efficiency, consumes, efficiencies)
		_execute(efficiency, produces, efficiencies)
	SignalBus.worker_efficiency_updated.emit(efficiencies)


func _execute(efficiency: int, target_resources: Dictionary, efficiencies: Dictionary) -> void:
	for resource_id: String in target_resources:
		var base_amount: int = target_resources[resource_id]
		var total_amount: int = efficiency * base_amount
		SignalBus.resource_generated.emit(resource_id, total_amount, self.name)
		efficiencies[resource_id] = efficiencies.get(resource_id, 0) + total_amount


static func _get_efficiency(worker_count: int, consumes: Dictionary, resources: Dictionary) -> int:
	var max_efficiency: int = worker_count
	for consume_id: String in consumes:
		var consume_amount: int = consumes[consume_id]
		var resource_amount: int = resources.get(consume_id, 0)
		var efficiency: int = min(resource_amount / consume_amount, worker_count)
		max_efficiency = min(efficiency, max_efficiency)
	return max_efficiency
