class_name TextureRgbOffset
extends TextureRect

## tween params
var shader_simple_tween_duration: float = 0.5
var rl_max: float = 6
var rx_max: float = rl_max
var ry_max: float = rl_max

@onready var simple_tween: SimpleTween = %SimpleTween

###############
## overrides ##
###############


func _ready() -> void:
	play_animation(0)


###############
## animation ##
###############


func get_simple_tween() -> SimpleTween:
	return simple_tween


func play_animation(duration: float = shader_simple_tween_duration) -> void:
	if simple_tween.is_finished():
		_randomize_shader_simple_tween_direction()
		simple_tween.play_animation_during(duration)


func _randomize_shader_simple_tween_direction() -> void:
	var random_direction: Vector2 = Vector2(0, rl_max).rotated(randf_range(0, deg_to_rad(360)))
	rx_max = random_direction.x
	ry_max = random_direction.y


############
## export ##
############


func _shader_simple_tween(animation_percent: float) -> void:
	var rx: float
	var ry: float
	if animation_percent < 0.5:
		rx = 0 + (animation_percent * 2 * rx_max)
		ry = 0 + (animation_percent * 2 * ry_max)
	else:
		rx = ((1 - animation_percent) * 2 * rx_max)
		ry = ((1 - animation_percent) * 2 * ry_max)
	material.set_shader_parameter("r_displacement", [0, 0])
	material.set_shader_parameter("b_displacement", [rx, ry])
	material.set_shader_parameter("g_displacement", [rx, ry])
