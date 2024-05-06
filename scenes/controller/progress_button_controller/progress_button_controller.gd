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
	_pay_resources(cost)
	SignalBus.progress_button_paid.emit(resource_generator)

	var amount: int = resource_generator.get_amount()
	SignalBus.resource_generated.emit(id, amount)


func _can_pay(costs: Dictionary) -> bool:
	for id: String in costs.keys():
		var cost: int = costs[id]
		if SaveFile.resources.get(id, 0) < cost:
			return false
	return true


func _pay_resources(costs: Dictionary) -> void:
	for id: String in costs.keys():
		var cost: int = costs[id]
		SignalBus.resource_generated.emit(id, -cost)


func _on_progress_button_pressed(resource_generator: ResourceGenerator) -> void:
	_handle_progress_button_pressed(resource_generator)
