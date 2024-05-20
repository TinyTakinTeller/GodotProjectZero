extends MarginContainer

@onready var theme_toggle_button: MarginContainer = %ThemeToggleButton

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
	var theme_toggle_id: String = SaveFile.settings.get("theme", null)
	if theme_toggle_id != null:
		theme_toggle_button.set_from_toggle_id(theme_toggle_id)


#############
## signals ##
#############


func _connect_signals() -> void:
	owner.ready.connect(_on_owner_ready)


func _on_owner_ready() -> void:
	theme_toggle_button.toggle()
