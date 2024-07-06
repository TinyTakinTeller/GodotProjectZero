extends Node

const BUS_NAME_MAP: Dictionary = {"master": "Master", "music": "Music", "sfx": "SFX"}

###############
## overrides ##
###############


func _ready() -> void:
	_connect_signals()


##############
## handlers ##
##############


func _handle_on_toggle_button_pressed(id: String, toggle_id: String) -> void:
	if id == "theme":
		var theme: Resource = Resources.theme[toggle_id]
		SignalBus.set_ui_theme.emit(theme)

		if toggle_id == "dark":
			RenderingServer.set_default_clear_color(Color(0, 0, 0, 0))
		else:
			RenderingServer.set_default_clear_color(Color(0.302, 0.302, 0.302, 1.0))

	SignalBus.toggle_button.emit(id, toggle_id)


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.toggle_button_pressed.connect(_on_toggle_button_pressed)
	SignalBus.toggle_scale_pressed.connect(_on_toggle_scale_pressed)
	SignalBus.audio_settings_update.connect(_on_audio_settings_update)


func _on_toggle_button_pressed(id: String, toggle_id: String) -> void:
	_handle_on_toggle_button_pressed(id, toggle_id)


func _on_toggle_scale_pressed(scale: int) -> void:
	SignalBus.toggle_scale.emit(scale)


func _on_audio_settings_update(toggle: bool, value: float, id: String) -> void:
	var bus_name: String = BUS_NAME_MAP[id]
	var bus_index: int = AudioServer.get_bus_index(bus_name)
	var volume_db: float = linear_to_db(value)
	AudioServer.set_bus_volume_db(bus_index, volume_db)
	AudioServer.set_bus_mute(bus_index, not toggle)

	SignalBus.audio_settings_updated.emit(toggle, value, id)
