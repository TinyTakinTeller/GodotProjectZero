extends Node


func _ready() -> void:
	SignalBus.progress_button_pressed.connect(_on_progress_button_pressed)


func _handle_progress_button_pressed(resource_generator: ResourceGenerator) -> void:
	var id: String = resource_generator.id
	var resource_amount: int = SaveFile.resources.get(id, 0) + 1
	var cost: Dictionary = resource_generator.get_scaled_costs(resource_amount)
	if !_can_pay(cost):
		SignalBus.progress_button_unpaid.emit(resource_generator)
		return
	_pay_resources(cost, resource_generator)
	SignalBus.progress_button_paid.emit(resource_generator)

	var generate: Dictionary = resource_generator.generate()
	for gen_id: String in generate:
		var amount: int = generate[gen_id]
		SignalBus.resource_generated.emit(gen_id, amount, resource_generator.id)


func _can_pay(costs: Dictionary) -> bool:
	for id: String in costs:
		var cost: int = costs[id]
		if SaveFile.resources.get(id, 0) < cost:
			return false
	return true


func _pay_resources(costs: Dictionary, resource_generator: ResourceGenerator) -> void:
	for gen_id: String in costs:
		var cost: int = costs[gen_id]
		SignalBus.resource_generated.emit(gen_id, -cost, resource_generator.id)


func _on_progress_button_pressed(resource_generator: ResourceGenerator) -> void:
	_handle_progress_button_pressed(resource_generator)
