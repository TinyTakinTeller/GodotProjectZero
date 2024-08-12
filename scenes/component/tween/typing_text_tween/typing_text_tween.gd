class_name TypingTextTween
extends Node

signal animation_end

@export var target: Node

var _tween: Tween
var _duration: float
var _loop: bool = false


func set_loop(loop: bool) -> void:
	_loop = loop


func play_animation(duration: float, loop: bool = false) -> void:
	if duration == 0.0:
		if _tween != null:
			_tween.kill()
		target.visible_ratio = 1.0
		animation_end.emit()
		return

	_loop = loop
	_duration = duration
	target.visible_ratio = 0.0
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_method(tween_method, 0.0, 1.0, _duration)
	_tween.tween_callback(on_animation_end)


func tween_method(animation_percent: float) -> void:
	target.visible_ratio = min(animation_percent, 1.0)


func on_animation_end() -> void:
	if _loop:
		play_animation(_duration, _loop)
	else:
		target.visible_ratio = 1.0
		animation_end.emit()
