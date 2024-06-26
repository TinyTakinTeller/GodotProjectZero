extends MarginContainer

@onready var theme_toggle_button: MarginContainer = %ThemeToggleButton
@onready var version_label: Label = %VersionLabel
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var audio_button: Button = $MarginContainer/HBoxContainer/MarginContainer/AudioButton

###############
## overrides ##
###############


func _ready() -> void:
	_load_from_save_file()
	_connect_signals()


#############
## helpers ##
#############


func _load_from_save_file() -> void:
	version_label.text = Game.VERSION_MAJOR + "\n" + Game.VERSION_MINOR

	var theme_toggle_id: String = SaveFile.settings.get("theme", null)
	if theme_toggle_id != null:
		theme_toggle_button.set_from_toggle_id(theme_toggle_id)


#############
## signals ##
#############


func _connect_signals() -> void:
	owner.ready.connect(_on_owner_ready)
	audio_button.button_down.connect(_on_audio_button_down)


func _on_owner_ready() -> void:
	theme_toggle_button.toggle()


func _on_audio_button_down() -> void:
	audio_stream_player.play()
	version_label.modulate.b -= 0.1
