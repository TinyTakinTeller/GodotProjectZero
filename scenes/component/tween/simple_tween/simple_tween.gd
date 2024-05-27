extends Node
class_name SimpleTween

signal animation_end

@export var target: Node
@export var duration: float = 1.0
@export var call_method: String
@export var loop: bool = false
@export var autostart: bool = false

var finished: bool = true

var _tween: Tween


func _ready() -> void:
	if autostart:
		play_animation()


func is_finished() -> bool:
	return finished


func play_animation() -> void:
	play_animation_(0)


func play_animation_(override_duration: float) -> void:
	finished = false
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	if override_duration == 0:
		override_duration = duration
	_tween.tween_method(tween_method, 0.0, 1.0, override_duration)
	_tween.tween_callback(on_animation_end)


func tween_method(animation_percent: float) -> void:
	target.call(call_method, animation_percent)


func on_animation_end() -> void:
	animation_end.emit()
	if loop:
		play_animation()
	else:
		finished = true
