class_name Player3D
extends CharacterBody3D

@export var max_rotation_angle_x: float = 30.0  #90.0
@export var max_rotation_angle_y: float = 30.0  #90.0

@onready var player_mesh_instance_3d: MeshInstance3D = %PlayerMeshInstance3D
@onready var player_camera_3d: Camera3D = %PlayerCamera3D

###############
## overrides ##
###############


func _process(_delta: float) -> void:
	_update_camera_rotation()


#############
## methods ##
#############


func get_mesh() -> MeshInstance3D:
	return player_mesh_instance_3d


#############
## helpers ##
#############


## Function to update camera rotation based on mouse position
func _update_camera_rotation() -> void:
	var screen_size: Vector2 = get_viewport().get_visible_rect().size
	var screen_center: Vector2 = screen_size / 2
	var mouse_position: Vector2 = get_viewport().get_mouse_position()

	# Restrict mouse location to game screen (viewport)
	var target_position: Vector2 = mouse_position
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	target_position.x = min(max(target_position.x, 0), viewport_size.x)
	target_position.y = min(max(target_position.y, 0), viewport_size.y)

	# Normalize the mouse movement relative to the screen center
	var normalized_x: float = (target_position.x - screen_center.x) / screen_center.x
	var normalized_y: float = (target_position.y - screen_center.y) / screen_center.y

	# Calculate target rotation
	var target_y_rotation: float = -normalized_x * max_rotation_angle_y
	var target_x_rotation: float = -normalized_y * max_rotation_angle_x

	# Apply rotation directly to the camera, using lerp for smoothing
	var new_rotation_x: float = lerp(player_camera_3d.rotation_degrees.x, target_x_rotation, 0.1)
	var new_rotation_y: float = lerp(
		player_camera_3d.get_parent().rotation_degrees.y, target_y_rotation, 0.1
	)

	# Update the camera's pitch (X-axis)
	player_camera_3d.rotation_degrees.x = new_rotation_x

	# Update the player's yaw (Y-axis) by rotating the parent node (usually the player or body node)
	player_camera_3d.get_parent().rotation_degrees.y = new_rotation_y


func _ready() -> void:
	pass
