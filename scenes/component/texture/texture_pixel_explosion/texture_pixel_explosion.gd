extends TextureRect
class_name TexturePixelExplosion

@onready var simple_tween: SimpleTween = %SimpleTween

## tween params
var death_animation_duration: float = 1.0
var death_animation_end_delay: float = 0.3
var death_animation_duration_fast: float = 0.8
var death_animation_end_delay_fast: float = 0.2

###############
## overrides ##
###############


func _ready() -> void:
	pass


###########
## setup ##
###########


func set_fast_mode(fast: bool) -> void:
	if fast:
		simple_tween.duration = death_animation_duration_fast
		simple_tween.end_delay = death_animation_end_delay_fast
	else:
		simple_tween.duration = death_animation_duration
		simple_tween.end_delay = death_animation_end_delay


###############
## animation ##
###############


func get_simple_tween() -> SimpleTween:
	return simple_tween


func play_animation() -> void:
	simple_tween.play_animation(false)


func play_reverse_animation() -> void:
	simple_tween.play_animation(true)


############
## export ##
############


func _shader_simple_tween(animation_percent: float) -> void:
	material.set_shader_parameter("progress", animation_percent)
