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
	SignalBus.toggle_manager_mode.connect(_on_toggle_manager_mode)
	SignalBus.toggle_darkness_mode.connect(_on_toggle_darkness_mode)
	SignalBus.audio_settings_updated.connect(_on_audio_settings_updated)
	SignalBus.effect_settings_updated.connect(_on_effect_settings_updated)
	SignalBus.display_mode_settings_updated.connect(_on_display_mode_settings_updated)
	SignalBus.display_resolution_settings_updated.connect(_on_display_resolution_settings_updated)


func _on_toggle_button(id: String, toggle_id: String) -> void:
	SaveFile.settings[id] = toggle_id


func _on_toggle_scale(scale: int) -> void:
	SaveFile.settings["population_scale"] = scale


func _on_toggle_manager_mode(mode: int) -> void:
	SaveFile.settings["manager_mode"] = mode


func _on_toggle_darkness_mode(mode: int) -> void:
	SaveFile.settings["darkness_mode"] = mode


func _on_audio_settings_updated(toggle: bool, value: float, id: String) -> void:
	SaveFile.audio_settings[id]["toggle"] = toggle
	SaveFile.audio_settings[id]["value"] = value


func _on_effect_settings_updated(toggle: bool, value: float, id: String) -> void:
	SaveFile.effect_settings[id]["toggle"] = toggle
	SaveFile.effect_settings[id]["value"] = value


func _on_display_mode_settings_updated(display_mode: String) -> void:
	SaveFile.settings["display_mode"] = display_mode


func _on_display_resolution_settings_updated(width: int, height: int) -> void:
	SaveFile.settings["display_resolution"] = [width, height]
