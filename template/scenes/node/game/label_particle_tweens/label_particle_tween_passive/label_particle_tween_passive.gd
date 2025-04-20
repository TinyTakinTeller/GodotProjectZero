class_name LabelParticleTweenPassive
extends LabelParticleTween

var rotation_velocity_spread: float = 0.3
var direction: float = 0
var direction_spread: float = 15

var _rotation_velocity: float = 0


func _process(delta: float) -> void:
	self.rotation += delta * _rotation_velocity


func flush() -> void:
	_rotation_velocity = randf_range(-rotation_velocity_spread, rotation_velocity_spread)
	self.rotation = deg_to_rad(randf_range(-direction_spread, direction_spread) / 2 + direction)

	self.text = "+%s %s" % [_format(label_amount), label_title]
	particle_tween.start()
