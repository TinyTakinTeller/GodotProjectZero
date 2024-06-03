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
	SignalBus.toggle_button.connect(_on_toggle_button)
	SignalBus.toggle_scale.connect(_on_toggle_scale)


func _on_toggle_button(id: String, toggle_id: String) -> void:
	SaveFile.settings[id] = toggle_id


func _on_toggle_scale(scale_: int) -> void:
	SaveFile.set_settings_population_scale(scale_)
