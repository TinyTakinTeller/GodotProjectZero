extends MarginContainer

const TAB_DATA_ID: String = "settings"

@onready var master_settings_slider: SettingsSlider = %MasterSettingsSlider
@onready var music_settings_slider: SettingsSlider = %MusicSettingsSlider
@onready var sfx_settings_slider: SettingsSlider = %SFXSettingsSlider

###############
## overrides ##
###############


func _ready() -> void:
	_initialize()
	_connect_signals()
	_load_from_save_file()


#############
## helpers ##
#############


func _initialize() -> void:
	master_settings_slider.title_label.text = Locale.get_ui_label("master")
	music_settings_slider.title_label.text = Locale.get_ui_label("music")
	sfx_settings_slider.title_label.text = Locale.get_ui_label("sfx")


func _load_from_save_file() -> void:
	master_settings_slider.set_data(
		SaveFile.audio_settings["master"]["toggle"], SaveFile.audio_settings["master"]["value"]
	)
	music_settings_slider.set_data(
		SaveFile.audio_settings["music"]["toggle"], SaveFile.audio_settings["music"]["value"]
	)
	sfx_settings_slider.set_data(
		SaveFile.audio_settings["sfx"]["toggle"], SaveFile.audio_settings["sfx"]["value"]
	)


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.tab_changed.connect(_on_tab_changed)
	master_settings_slider.data_changed.connect(_on_data_changed.bind("master"))
	music_settings_slider.data_changed.connect(_on_data_changed.bind("music"))
	sfx_settings_slider.data_changed.connect(_on_data_changed.bind("sfx"))


func _on_tab_changed(tab_data: TabData) -> void:
	if tab_data.id == TAB_DATA_ID:
		visible = true
	else:
		visible = false


func _on_data_changed(toggle: bool, value: float, id: String) -> void:
	SignalBus.audio_settings_update.emit(toggle, value, id)
