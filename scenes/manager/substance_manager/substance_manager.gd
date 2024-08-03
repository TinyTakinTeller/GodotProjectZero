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


func _handle_on_substance_generated(id: String) -> void:
	SaveFile.substances[id] = SaveFile.substances.get(id, 0) + 1
	SignalBus.substance_updated.emit(id, SaveFile.substances[id])


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.substance_generated.connect(_on_substance_generated)


func _on_substance_generated(id: String) -> void:
	_handle_on_substance_generated(id)
