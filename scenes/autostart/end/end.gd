extends Node3D

@onready var player_character_body_3d: Player3D = $PlayerCharacterBody3D
@onready var label_3d: Label3D = %Label3D

###############
## overrides ##
###############


func _ready() -> void:
	_initialize()


#############
## helpers ##
#############


func _initialize() -> void:
	player_character_body_3d.get_mesh().visible = false
	label_3d.text = Locale.get_ui_label("thank_you")

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
