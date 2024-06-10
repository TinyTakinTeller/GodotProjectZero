extends TextureRect
class_name TexturePixelExplosion

@onready var simple_tween: SimpleTween = %SimpleTween

###############
## overrides ##
###############


func _ready() -> void:
	pass


###############
## animation ##
###############


func get_simple_tween() -> SimpleTween:
	return simple_tween


func play_animation(reverse: bool = false) -> void:
	simple_tween.play_animation(reverse)


############
## export ##
############


func _shader_simple_tween(animation_percent: float) -> void:
	material.set_shader_parameter("progress", animation_percent)
