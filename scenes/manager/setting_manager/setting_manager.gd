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
	SignalBus.audio_settings_updated.connect(_on_audio_settings_updated)


func _on_toggle_button(id: String, toggle_id: String) -> void:
	SaveFile.settings[id] = toggle_id


func _on_toggle_scale(scale: int) -> void:
	SaveFile.settings["population_scale"] = scale


func _on_audio_settings_updated(toggle: bool, value: float, id: String) -> void:
	SaveFile.audio_settings[id]["toggle"] = toggle
	SaveFile.audio_settings[id]["value"] = value
