extends Node

###############
## overrides ##
###############


func _ready() -> void:
	_connect_signals()


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.toggle_button_pressed.connect(_on_toggle_button_pressed)


func _on_toggle_button_pressed(id: String, toggle_id: String) -> void:
	SaveFile.settings[id] = toggle_id
