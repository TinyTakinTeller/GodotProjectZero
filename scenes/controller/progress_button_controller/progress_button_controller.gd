extends Node

@export var worker_controller: WorkerController

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


func _pay_resources(costs: Dictionary, id: String, factor: int = 1) -> void:
	for gen_id: String in costs:
		var cost: int = costs[gen_id] * factor
		SignalBus.resource_generated.emit(gen_id, -cost, id)


func _can_pay_worker(worker_costs: Dictionary) -> bool:
	if not worker_costs.is_empty() and SaveFile.workers.get(Game.WORKER_RESOURCE_ID, 0) <= 0:
		return false
	var house: int = SaveFile.resources.get("house", 0)
	if house >= Limits.GLOBAL_MAX_AMOUNT:
		return true  # QOL edge case dirty worakround, don't touch don't ask... ⚰️

	for id: String in worker_costs:
		var cost: int = worker_costs[id]
		if SaveFile.workers.get(id, 0) < cost:
			return false
	return true


func _pay_workers(worker_costs: Dictionary, _id: String, factor: int = 1) -> void:
	for gen_id: String in worker_costs:
		var cost: int = worker_costs[gen_id] * factor
		SignalBus.worker_generated.emit(gen_id, -cost, name)


func _get_eff(costs: Dictionary, max_factor: int = Limits.GLOBAL_MAX_AMOUNT) -> int:
	var max_eff: int = max_factor
	for id: String in costs:
		var cost: int = costs[id]
		var amount: int = SaveFile.resources.get(id, 0)
		var eff: int = amount / cost
		max_eff = min(max_eff, eff)
	return max(0, max_eff)


func _get_worker_eff(costs: Dictionary, max_factor: int = Limits.GLOBAL_MAX_AMOUNT) -> int:
	if max_factor <= 0:
		return 0
	var house: int = SaveFile.resources.get("house", 0)
	if house >= Limits.GLOBAL_MAX_AMOUNT:
		return Limits.GLOBAL_MAX_AMOUNT  # QOL edge case dirty worakround, don't touch don't ask... ⚰️

	var max_eff: int = max_factor
	for id: String in costs:
		var cost: int = costs[id]
		var amount: int = SaveFile.workers.get(id, 0)
		var eff: int = amount / cost
		max_eff = min(max_eff, eff)
	return max(0, max_eff)


##############
## handlers ##
##############


func _handle_progress_button_pressed(resource_generator: ResourceGenerator, source: String) -> void:
	if resource_generator == null:
		return

	## TODO: game ending
	if resource_generator.id == "soul":
		var cost: Dictionary = resource_generator.get_costs()
		if _can_pay(cost):
			SignalBus.soul.emit()
		SignalBus.progress_button_unpaid.emit(resource_generator, source)
		return

	var id: String = resource_generator.id
	var resource_amount: int = SaveFile.resources.get(id, 0) + 1
	var resource_cost: Dictionary = resource_generator.get_scaled_costs(resource_amount)
	var worker_cost: Dictionary = resource_generator.get_worker_costs()

	var no_costs: bool = resource_cost.is_empty() and worker_cost.is_empty()
	var for_charm: bool = no_costs or id in ["brick", "house", "torch", "sword", "swordsman"]
	var has_hermit: bool = SaveFile.substances.get("the_hermit", 0) > 0
	var has_strength: bool = SaveFile.substances.get("strength", 0) > 0
	var strenth_factor: int = 1
	if for_charm and has_strength:
		var peasants: int = SaveFile.workers.get(Game.WORKER_RESOURCE_ID, 0)
		strenth_factor = min(
			_get_worker_eff(worker_cost, peasants), _get_eff(resource_cost, peasants)
		)

		# do not allow clicks to go into negative food efficiency
		if id == "swordsman":
			var food_eff: int = worker_controller.get_efficiencies().get("resources", {}).get(
				"food", 0
			)
			if food_eff <= 0:
				strenth_factor = 1
			else:
				strenth_factor = min(strenth_factor, _get_worker_eff(worker_cost, food_eff))

		# do not consume costs if overshot MAX amount
		var max_generation_amount: int = max(Limits.GLOBAL_MAX_AMOUNT - resource_amount, 0)
		strenth_factor = min(strenth_factor, max_generation_amount)

	if !Game.PARAMS["debug_free_resource_buttons"]:
		if !_can_pay(resource_cost) or !_can_pay_worker(worker_cost):
			SignalBus.progress_button_unpaid.emit(resource_generator, source)
			return
		_pay_resources(resource_cost, id, strenth_factor)
		_pay_workers(worker_cost, id, strenth_factor)
	SignalBus.progress_button_paid.emit(resource_generator, source)

	var generate: Dictionary = resource_generator.generate()
	for gen_id: String in generate:
		var amount: int = generate[gen_id]
		if for_charm:
			if has_hermit:
				var experience: int = SaveFile.resources.get("experience", 1)
				var house: int = SaveFile.resources.get("house", 0)
				if id == "swordsman" and house < experience:  # workaround
					var house_workers: int = SaveFile.get_house_workers()
					experience = min(experience, Limits.safe_mult(house_workers, house))
				amount = Limits.safe_mult(experience, amount)
			if has_strength:
				amount = Limits.safe_add(strenth_factor, amount)
		SignalBus.resource_generated.emit(gen_id, amount, resource_generator.id)


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.progress_button_pressed.connect(_on_progress_button_pressed)


func _on_progress_button_pressed(resource_generator: ResourceGenerator, source: String) -> void:
	_handle_progress_button_pressed(resource_generator, source)
