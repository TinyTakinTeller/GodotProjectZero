extends Node
class_name WorkerController

const CYCLE_SECONDS: int = Game.params["cycle_seconds"]

@onready var timer: Timer = $Timer

###############
## overrides ##
###############


func _ready() -> void:
	_initialize()
	_connect_signals()


#############
## helpers ##
#############


func _initialize() -> void:
	timer.wait_time = CYCLE_SECONDS
	timer.start()


func _generate_resources_from_workers(generate: bool = true) -> void:
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
		_execute(-efficiency, consumes, efficiencies, generate)
		_execute(efficiency, produces, efficiencies, generate)
	SignalBus.worker_efficiency_updated.emit(efficiencies)


func _execute(
	efficiency: int, target_resources: Dictionary, efficiencies: Dictionary, generate: bool = true
) -> void:
	for resource_id: String in target_resources:
		var base_amount: int = target_resources[resource_id]
		var total_amount: int = efficiency * base_amount
		if generate:
			SignalBus.resource_generated.emit(resource_id, total_amount, self.name)
		efficiencies[resource_id] = efficiencies.get(resource_id, 0) + total_amount


#############
## signals ##
#############


func _connect_signals() -> void:
	timer.timeout.connect(_on_timeout)
	owner.ready.connect(_on_owner_ready)


func _on_timeout() -> void:
	_generate_resources_from_workers()


func _on_owner_ready() -> void:
	_generate_resources_from_workers(false)


############
## static ##
############


static func _get_efficiency(worker_count: int, consumes: Dictionary, resources: Dictionary) -> int:
	var max_efficiency: int = worker_count
	for consume_id: String in consumes:
		var consume_amount: int = consumes[consume_id]
		var resource_amount: int = resources.get(consume_id, 0)
		var efficiency: int = min(resource_amount / consume_amount, worker_count)
		max_efficiency = min(efficiency, max_efficiency)
	return max_efficiency
