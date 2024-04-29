extends Node
class_name ResourceManager


func _ready() -> void:
	SignalBus.progress_button_pressed.connect(_on_progress_button_pressed)


func _handle_progress_button_pressed(resource_generator: ResourceGenerator) -> void:
	var cost: Dictionary = resource_generator.get_cost()
	if !_can_pay(cost):
		SignalBus.progress_button_unpaid.emit(resource_generator)
		return
	_pay_resources(cost)
	SignalBus.progress_button_paid.emit(resource_generator)

	var id: String = resource_generator.id
	var amount: int = resource_generator.get_amount()
	_add_resource(id, amount)
	SignalBus.event_triggered.emit(id, {"amount": amount})


func _can_pay(costs: Dictionary) -> bool:
	for id: String in costs.keys():
		var cost: int = costs[id]
		if SaveFile.resources.get(id, 0) < cost:
			return false
	return true


func _pay_resources(costs: Dictionary) -> void:
	for id: String in costs.keys():
		var cost: int = costs[id]
		SaveFile.resources[id] -= cost
		SignalBus.resource_updated.emit(id, SaveFile.resources[id], -cost)


func _add_resource(id: String, amount: int) -> void:
	SaveFile.resources[id] = SaveFile.resources.get(id, 0) + amount
	SignalBus.resource_updated.emit(id, SaveFile.resources[id], amount)


func _on_progress_button_pressed(resource_generator: ResourceGenerator) -> void:
	_handle_progress_button_pressed(resource_generator)
