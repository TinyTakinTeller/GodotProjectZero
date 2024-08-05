extends MarginContainer

@export var sfx_fart: AudioStream

@onready var theme_toggle_button: MarginContainer = %ThemeToggleButton
@onready var version_label: Label = %VersionLabel
@onready var version_button: Button = %VersionButton

###############
## overrides ##
###############


func _ready() -> void:
	_connect_signals()
	_load_from_save_file()


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
	version_button.button_down.connect(_on_version_button_down)


func _on_owner_ready() -> void:
	theme_toggle_button.toggle()


func _on_version_button_down() -> void:
	Audio.play_sfx("fart", sfx_fart)
