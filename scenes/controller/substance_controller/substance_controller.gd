class_name SubstanceController
extends Node

@onready var death_timer: Timer = %DeathTimer

###############
## overrides ##
###############


func _ready() -> void:
	_connect_signals()
	_initialize()


#############
## helpers ##
#############


func _initialize() -> void:
	if SaveFile.get_prestige_count() > 1:
		var time: float = max(1.0, SaveFile.best_prestige_delta())
		death_timer.start(time)


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
	death_timer.timeout.connect(_on_death_timer)


func _on_substance_craft_button_pressed(substance_data: SubstanceData) -> void:
	_handle_substance_craft_button_pressed(substance_data)


func _on_progress_button_paid(resource_generator: ResourceGenerator, _source: String) -> void:
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


func _on_death_timer() -> void:
	var has_death: bool = SaveFile.substances.get("death", 0) > 0
	if not has_death:
		return

	SignalBus.substance_generated.emit("heart", name)
	SignalBus.resource_generated.emit("singularity", 18, name)
