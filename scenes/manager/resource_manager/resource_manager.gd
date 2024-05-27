extends Node
class_name ResourceManager

###############
## overrides ##
###############


func _ready() -> void:
	_connect_signals()


##############
## handlers ##
##############


func _handle_on_resource_generated(id: String, amount: int, source_id: String) -> void:
	SaveFile.resources[id] = SaveFile.resources.get(id, 0) + amount
	if amount < 0:
		var spent_id: String = ResourceManager._spent_id(id)
		SaveFile.resources[spent_id] = SaveFile.resources.get(spent_id, 0) - amount
	SignalBus.resource_updated.emit(id, SaveFile.resources.get(id, 0), amount, source_id)

	if Game.WORKER_ROLE_RESOURCE.has(id):
		SignalBus.worker_generated.emit(id, amount, self.name)

	if ResourceManager.is_max_amount_reached(id):
		SignalBus.progress_button_disabled.emit(id)
		return


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.resource_generated.connect(_on_resource_generated)


func _on_resource_generated(id: String, amount: int, source_id: String) -> void:
	_handle_on_resource_generated(id, amount, source_id)


############
## static ##
############


static func is_max_amount_reached(id: String) -> bool:
	var resource_generator: ResourceGenerator = Resources.resource_generators[id]
	var max_amount: int = resource_generator.max_amount
	return max_amount > -1 and SaveFile.resources.get(id, 0) >= max_amount


static func get_total_generated(id: String) -> int:
	return SaveFile.resources.get(id, 0) + SaveFile.resources.get(ResourceManager._spent_id(id), 0)


static func _spent_id(id: String) -> String:
	return "spent_" + id
