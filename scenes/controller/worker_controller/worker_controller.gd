extends Node
class_name WorkerController

signal none

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


func _generate(generate: bool = true) -> void:
	var efficiencies: Dictionary = _calculate_generated_amounts()
	var new_workers: int = _calculate_generated_worker_resource_from_houses()
	efficiencies["resources"][Game.WORKER_RESOURCE_ID] = (
		efficiencies["resources"].get(Game.WORKER_RESOURCE_ID, 0) + new_workers
	)

	if generate:
		var generated_resources: Dictionary = efficiencies["resources"]
		var generated_workers: Dictionary = efficiencies["workers"]
		for resource_id: String in generated_resources:
			var amount: int = generated_resources[resource_id]
			SignalBus.resource_generated.emit(resource_id, amount, self.name)
		for worker_id: String in generated_workers:
			var amount: int = generated_workers[worker_id]
			SignalBus.worker_generated.emit(worker_id, amount, self.name)

	SignalBus.worker_efficiency_set.emit(efficiencies, generate)


func _calculate_generated_worker_resource_from_houses() -> int:
	var resource_id: String = Game.WORKER_RESOURCE_ID
	var per_house: int = Game.params["house_workers"]
	var max_workers: int = per_house * SaveFile.resources.get("house", 0)
	var current_workers: int = SaveFile.resources.get(resource_id, 0)
	if current_workers < max_workers:
		var amount: int = 1 + int((max_workers - current_workers - 1) / per_house)
		return amount
	return 0


func _calculate_generated_amounts() -> Dictionary:
	var resources: Dictionary = SaveFile.resources.duplicate(true)
	var generated_resources: Dictionary = {}
	var generated_workers: Dictionary = {}

	for worker_role_id: String in SaveFile.workers:
		var count: int = SaveFile.workers[worker_role_id]
		if count == 0:
			continue
		var worker_role: WorkerRole = Resources.worker_roles[worker_role_id]
		var r_consume: Dictionary = worker_role.get_consume()
		var w_consume: Dictionary = worker_role.get_worker_consume()
		var produces: Dictionary = worker_role.get_produce()

		var resources_eff: int = WorkerController._get_efficiency(count, r_consume, resources)
		var workers_eff: int = WorkerController._get_efficiency(count, w_consume, SaveFile.workers)
		var efficiency: int = min(resources_eff, workers_eff)
		if efficiency == 0:
			continue
		_generate_from(resources, -efficiency, generated_resources, r_consume)
		_generate_from(resources, -efficiency, generated_workers, w_consume)
		_generate_from(resources, efficiency, generated_resources, produces)

	return {"resources": generated_resources, "workers": generated_workers}


func _generate_from(
	resources: Dictionary, eff: int, generated: Dictionary, ids: Dictionary
) -> void:
	for id: String in ids:
		var base_amount: int = ids[id]
		var amount: int = eff * base_amount
		generated[id] = generated.get(id, 0) + amount
		resources[id] = resources.get(id, 0) + amount


#############
## signals ##
#############


func _connect_signals() -> void:
	timer.timeout.connect(_on_timeout)
	owner.ready.connect(_on_owner_ready)
	SignalBus.worker_updated.connect(_on_worker_updated)


func _on_timeout() -> void:
	_generate()


func _on_owner_ready() -> void:
	_generate(false)


func _on_worker_updated(_id: String, _total: int, _amount: int) -> void:
	_generate(false)


############
## static ##
############


static func _get_efficiency(worker_count: int, consumes: Dictionary, items: Dictionary) -> int:
	var max_efficiency: int = worker_count
	for consume_id: String in consumes:
		var consume_amount: int = consumes[consume_id]
		var resource_amount: int = items.get(consume_id, 0)
		var efficiency: int = min(resource_amount / consume_amount, worker_count)
		max_efficiency = min(efficiency, max_efficiency)
	return max_efficiency
