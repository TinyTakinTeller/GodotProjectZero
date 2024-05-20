extends Node

signal animation_end

@export var target: Node

var _tween: Tween


func play_animation(duration: float) -> void:
	target.visible_ratio = 0
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_method(tween_method, 0.0, 1.0, duration)
	_tween.tween_callback(on_animation_end)


func tween_method(animation_percent: float) -> void:
	target.visible_ratio = animation_percent


func on_animation_end() -> void:
	target.visible_ratio = 1
	animation_end.emit()
