extends MarginContainer

@onready var theme_toggle_button: MarginContainer = %ThemeToggleButton
@onready var version_label: Label = %VersionLabel
@onready var version_button: Button = %VersionButton

###############
## overrides ##
###############


func _ready() -> void:
	_load_from_save_file()


#############
## helpers ##
#############


func _load_from_save_file() -> void:
	if Game.VERSION_MAJOR == "":
		version_label.text = Game.VERSION_MINOR
	else:
		version_label.text = Game.VERSION_MAJOR + "\n" + Game.VERSION_MINOR

	var theme_toggle_id: String = SaveFile.settings.get("theme", null)
	if theme_toggle_id != null:
		theme_toggle_button.set_from_toggle_id(theme_toggle_id)


#############
## signals ##
#############


func _on_owner_ready() -> void:
	theme_toggle_button.toggle()
