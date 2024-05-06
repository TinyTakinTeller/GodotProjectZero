extends Node
class_name ResourceManager


func _ready() -> void:
	SignalBus.resource_generated.connect(_on_resource_generated)


func _add_resource(id: String, amount: int) -> void:
	SaveFile.resources[id] = SaveFile.resources.get(id, 0) + amount
	SignalBus.resource_updated.emit(id, SaveFile.resources[id], amount)


func _on_resource_generated(id: String, amount: int) -> void:
	_add_resource(id, amount)
