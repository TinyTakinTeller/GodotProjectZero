extends Node

@export var target: Node
@export var loop: bool = true
@export var on_ready: bool = false
@export var duration: float = 0.3
@export var base_change: float = 0
@export var max_change: float = 0.1

var _tween: Tween


func _ready() -> void:
	if on_ready:
		play_animation()


func play_animation() -> void:
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_method(tween_method, 0.0, 1.0, duration)
	_tween.tween_callback(on_animation_end)


func tween_method(animation_percent: float) -> void:
	var base: float = base_change
	var change: float = animation_percent * max_change
	if animation_percent < 0.25:
		base += 0
		target.rotation = base + change
	elif animation_percent < 0.50:
		base += 2 * (0.25 * max_change)
		target.rotation = base - change
	elif animation_percent < 0.75:
		base += 2 * (0.25 * max_change)
		target.rotation = base - change
	else:
		base -= 4 * (0.25 * max_change)
		target.rotation = base + change


func on_animation_end() -> void:
	if loop:
		play_animation()
