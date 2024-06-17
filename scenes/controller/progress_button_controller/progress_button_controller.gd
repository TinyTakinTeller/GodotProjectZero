extends Node

###############
## overrides ##
###############


func _ready() -> void:
	_connect_signals()


#############
## helpers ##
#############


func _can_pay(costs: Dictionary) -> bool:
	for id: String in costs:
		var cost: int = costs[id]
		if SaveFile.resources.get(id, 0) < cost:
			return false
	return true


func _pay_resources(costs: Dictionary, id: String) -> void:
	for gen_id: String in costs:
		var cost: int = costs[gen_id]
		SignalBus.resource_generated.emit(gen_id, -cost, id)


func _can_pay_worker(worker_costs: Dictionary) -> bool:
	for id: String in worker_costs:
		var cost: int = worker_costs[id]
		if SaveFile.workers.get(id, 0) < cost:
			return false
	return true


func _pay_workers(worker_costs: Dictionary, _id: String) -> void:
	for gen_id: String in worker_costs:
		var cost: int = worker_costs[gen_id]
		SignalBus.worker_generated.emit(gen_id, -cost, name)


##############
## handlers ##
##############


func _handle_progress_button_pressed(resource_generator: ResourceGenerator) -> void:
	var id: String = resource_generator.id
	var resource_amount: int = SaveFile.resources.get(id, 0) + 1
	var resource_cost: Dictionary = resource_generator.get_scaled_costs(resource_amount)
	var worker_cost: Dictionary = resource_generator.get_worker_costs()

	if !Game.params["debug_free_resource_buttons"]:
		if !_can_pay(resource_cost) or !_can_pay_worker(worker_cost):
			SignalBus.progress_button_unpaid.emit(resource_generator)
			return
		_pay_resources(resource_cost, id)
		_pay_workers(worker_cost, id)
	SignalBus.progress_button_paid.emit(resource_generator)

	var generate: Dictionary = resource_generator.generate()
	for gen_id: String in generate:
		var amount: int = generate[gen_id]
		SignalBus.resource_generated.emit(gen_id, amount, resource_generator.id)


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.progress_button_pressed.connect(_on_progress_button_pressed)


func _on_progress_button_pressed(resource_generator: ResourceGenerator) -> void:
	_handle_progress_button_pressed(resource_generator)
