class_name SubstanceManager
extends Node

###############
## overrides ##
###############


func _ready() -> void:
	_connect_signals()


##############
## handlers ##
##############


func _handle_on_substance_generated(id: String, source_id: String) -> void:
	SaveFile.substances[id] = SaveFile.substances.get(id, 0) + 1
	SignalBus.substance_updated.emit(id, SaveFile.substances[id], source_id)


func _handle_on_substance_multiple_generated(id: String, amount: int, source_id: String) -> void:
	SaveFile.substances[id] = SaveFile.substances.get(id, 0) + amount
	SignalBus.substance_updated.emit(id, SaveFile.substances[id], source_id)


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.substance_generated.connect(_on_substance_generated)
	SignalBus.substance_multiple_generated.connect(_on_substance_multiple_generated)


func _on_substance_generated(id: String, source_id: String) -> void:
	_handle_on_substance_generated(id, source_id)


func _on_substance_multiple_generated(id: String, amount: int, source_id: String) -> void:
	_handle_on_substance_multiple_generated(id, amount, source_id)
