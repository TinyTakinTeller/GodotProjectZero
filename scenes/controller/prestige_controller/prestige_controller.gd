class_name PrestigeController
extends Node

const MAX_INFINITY_COUNT: int = 16

###############
## overrides ##
###############


func _ready() -> void:
	_connect_signals()


#############
## handler ##
#############


func _handle_on_prestige_yes() -> void:
	if Game.PARAMS["prestige_disabled"]:
		SignalBus.prestige_condition_disabled.emit()
		return

	var infinity_progress: Dictionary = PrestigeController.get_infinity_progress()
	var infinity_count: int = infinity_progress["infinity_count"]

	if infinity_count <= 0:
		SignalBus.prestige_condition_fail.emit()
		return

	SignalBus.prestige_condition_pass.emit(infinity_count)


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.prestige_yes.connect(_on_prestige_yes)


func _on_prestige_yes() -> void:
	_handle_on_prestige_yes()


static func get_infinity_progress() -> Dictionary:
	var max_infinity_count: int = MAX_INFINITY_COUNT
	var max_amount: int = 0
	var max_resource_id: String = ""
	var max_resource_name: String = ""
	var infinity_count: int = 0
	for resource_id: String in SaveFile.resources:
		var resource_generator: ResourceGenerator = Resources.resource_generators.get(
			resource_id, null
		)
		if resource_generator == null or resource_generator.id == "soulstone":
			continue

		var amount: int = SaveFile.resources[resource_id]
		if amount >= Limits.GLOBAL_MAX_AMOUNT:
			infinity_count += 1
			if resource_id in ["flint", "fiber"]:  # TODO: make flint and fiber relevant in-game
				max_infinity_count += 1
		else:
			if max_amount < amount:
				max_amount = amount
				max_resource_id = resource_id
				max_resource_name = resource_generator.get_display_name()
	return {
		"max_infinity_count": max_infinity_count,
		"max_amount": max_amount,
		"max_resource_id": max_resource_id,
		"max_resource_name": max_resource_name,
		"infinity_count": infinity_count
	}
