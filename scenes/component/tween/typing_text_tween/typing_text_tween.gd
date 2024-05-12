extends Node

@export var target: Node


func _ready() -> void:
	pass


func play_animation(duration: float) -> void:
	var tween: Tween = target.create_tween()
	tween.tween_method(tween_method, 0.0, 1.0, duration)
	tween.tween_callback(on_animation_end)


func tween_method(animation_percent: float) -> void:
	target.visible_ratio = animation_percent


func on_animation_end() -> void:
	target.visible_ratio = 1
