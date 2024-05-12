extends Node
class_name SimpleTween

signal end

@export var target: Node
@export var duration: float = 1.0
@export var call_method: String


func _ready() -> void:
	pass


func play_animation() -> void:
	play_animation_(0)


func play_animation_(override_duration: float) -> void:
	var tween: Tween = target.create_tween()
	if override_duration == 0:
		override_duration = duration
	tween.tween_method(tween_method, 0.0, 1.0, override_duration)
	tween.tween_callback(on_animation_end)


func tween_method(animation_percent: float) -> void:
	target.call(call_method, animation_percent)


func on_animation_end() -> void:
	end.emit()
