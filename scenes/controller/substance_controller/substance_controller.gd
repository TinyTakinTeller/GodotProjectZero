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


##############
## handlers ##
##############


func _handle_substance_craft_button_pressed(substance_data: SubstanceData) -> void:
	var id: String = substance_data.get_id()
	var resource_cost: Dictionary = substance_data.get_resource_costs()

	if !Game.PARAMS["debug_free_resource_buttons"]:
		if !_can_pay(resource_cost):
			SignalBus.substance_craft_button_unpaid.emit(substance_data)
			return
		_pay_resources(resource_cost, id)
	SignalBus.substance_craft_button_paid.emit(substance_data)

	SignalBus.substance_generated.emit(id, name)


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.substance_craft_button_pressed.connect(_on_substance_craft_button_pressed)
	SignalBus.progress_button_paid.connect(_on_progress_button_paid)


func _on_substance_craft_button_pressed(substance_data: SubstanceData) -> void:
	_handle_substance_craft_button_pressed(substance_data)


func _on_progress_button_paid(resource_generator: ResourceGenerator) -> void:
	var has_world: bool = SaveFile.substances.get("the_world", 0) > 0
	var has_wheel: bool = SaveFile.substances.get("wheel_of_fortune", 0) > 0
	if not has_world:
		return

	var boost: int = 2 if has_wheel else 1
	var id: String = resource_generator.id
	if (randi() % (10 / boost)) == 0:
		SignalBus.substance_generated.emit("flesh", id)
	if (randi() % (100 / boost)) == 0:
		SignalBus.substance_generated.emit("eye", id)
	if (randi() % (1000 / boost)) == 0:
		SignalBus.substance_generated.emit("bone", id)
