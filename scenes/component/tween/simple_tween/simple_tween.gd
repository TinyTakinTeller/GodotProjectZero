extends Node
class_name SimpleTween

signal animation_end
signal animation_finished

@export var target: Node
@export var duration: float = 1.0
@export var end_delay: float = 0.0
@export var call_method: String
@export var loop: bool = false
@export var autostart: bool = false
@export var roundabout: bool = false

var finished: bool = true

var _tween: Tween
var _roundabout_flag: bool = false
var _reversed_flag: bool = false


func _ready() -> void:
	if autostart:
		play_animation()


func is_finished() -> bool:
	return finished


func play_animation(reverse: bool = false) -> void:
	play_animation_(0, reverse)


func play_animation_(override_duration: float, reverse: bool = false) -> void:
	_reversed_flag = reverse
	finished = false
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	if override_duration == 0:
		override_duration = duration
	var percent_delay: float = end_delay / override_duration
	if not reverse:
		_tween.tween_method(tween_method, 0.0, 1.0 + percent_delay, override_duration + end_delay)
	else:
		_tween.tween_method(tween_method, 1.0 + percent_delay, 0.0, override_duration + end_delay)
	_tween.tween_callback(on_animation_end)


func tween_method(animation_percent: float) -> void:
	if animation_percent <= 1.0:
		target.call(call_method, animation_percent)


func on_animation_end() -> void:
	animation_end.emit()

	if roundabout:
		if not _roundabout_flag:
			play_animation(not _reversed_flag)
			_roundabout_flag = not _roundabout_flag
			return
		_roundabout_flag = not _roundabout_flag

	if loop:
		play_animation()
		return

	finished = true
	animation_finished.emit()
