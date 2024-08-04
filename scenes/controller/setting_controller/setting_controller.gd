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
	SignalBus.toggle_manager_mode_pressed.connect(_on_toggle_manager_mode_pressed)
	SignalBus.audio_settings_update.connect(_on_audio_settings_update)
	SignalBus.effect_settings_update.connect(_on_effect_settings_update)
	SignalBus.display_mode_settings_toggle.connect(_on_display_mode_settings_toggle)
	SignalBus.display_resolution_settings_toggle.connect(_on_display_resolution_settings_toggle)


func _on_toggle_button_pressed(id: String, toggle_id: String) -> void:
	_handle_on_toggle_button_pressed(id, toggle_id)


func _on_toggle_scale_pressed(scale: int) -> void:
	SignalBus.toggle_scale.emit(scale)

func _on_toggle_manager_mode_pressed(mode: int) -> void:
	SignalBus.toggle_manager_mode.emit(mode)

func _on_audio_settings_update(toggle: bool, value: float, id: String) -> void:
	var bus_name: String = BUS_NAME_MAP[id]
	var bus_index: int = AudioServer.get_bus_index(bus_name)
	var volume_db: float = linear_to_db(value)
	AudioServer.set_bus_volume_db(bus_index, volume_db)
	AudioServer.set_bus_mute(bus_index, not toggle)

	SignalBus.audio_settings_updated.emit(toggle, value, id)


func _on_effect_settings_update(toggle: bool, value: float, id: String) -> void:
	SignalBus.effect_settings_updated.emit(toggle, value, id)


func _on_display_mode_settings_toggle() -> void:
	var display_mode: String = SaveFile.settings["display_mode"]
	if display_mode == "windowed":
		display_mode = "fullscreen"
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		display_mode = "windowed"
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	SignalBus.display_mode_settings_updated.emit(display_mode)


func _on_display_resolution_settings_toggle() -> void:
	var width: int = SaveFile.settings["display_resolution"][0]
	var height: int = SaveFile.settings["display_resolution"][1]
	## TODO: replace resolution setting with a different one

	SignalBus.display_resolution_settings_updated.emit(width, height)
