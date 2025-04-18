extends Node3D

var _exit: bool = false

@onready var player_character_body_3d: Player3D = $PlayerCharacterBody3D
@onready var label_3d: Label3D = %Label3D

###############
## overrides ##
###############


func _process(_delta: float) -> void:
	if (
		not _exit and Input.is_action_just_pressed("escape_game")
		or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	):
		_exit = true
		Scene.change_scene("save_file_picker_scene")


func _ready() -> void:
	_initialize()


#############
## helpers ##
#############


func _initialize() -> void:
	player_character_body_3d.get_mesh().visible = false
	label_3d.text = Locale.get_ui_label("thank_you")

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
