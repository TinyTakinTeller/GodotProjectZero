class_name ParticleTween
extends Node
## Emulates particle emitter with a tween. The [target] must have position and modulate properties.
## Example use case: [LabelParticleTween] set as PCK scene in [SpawnerBuffer] inside [GameButton].
## [br][br]
## Original File MIT License Copyright (c) 2024 TinyTakinTeller

signal finished

@export_group("Tween Options")
@export var target: Node

@export_group("Particle Options")
@export var duration: float = 3.0
@export var direction: float = 90
@export var direction_spread: float = 90
@export var speed: float = 275.0
@export var speed_spread: float = 50
@export var gravity: float = 200.0
## Helps prevent particles from spreading too far apart from origin.
@export_range(0, 1) var horizontal_damping: float = 0.4


func start() -> void:
	if target == null:
		return

	var tween: Tween = create_tween()
	var start_position: Vector2 = target.position
	var random_angle: float = randf_range(-direction_spread, direction_spread) / 2 + direction
	var random_speed: float = randf_range(-speed_spread, speed_spread) + speed
	var velocity: Vector2 = Vector2(
		random_speed * cos(deg_to_rad(random_angle)), -random_speed * sin(deg_to_rad(random_angle))
	)

	tween.tween_method(_update_arc_position.bind(start_position, velocity), 0.0, 1.0, duration)
	tween.parallel().tween_property(target, "modulate:a", 0.0, duration)
	tween.connect("finished", _on_tween_finished)


func _update_arc_position(progress: float, start_pos: Vector2, velocity: Vector2) -> void:
	var time: float = progress * duration
	var base_x: float = start_pos.x + velocity.x * time
	var base_y: float = start_pos.y + (velocity.y * time) + (0.5 * gravity * time * time)

	var center_attraction_strength: float = horizontal_damping * progress
	var final_x: float = lerp(base_x, start_pos.x, center_attraction_strength)

	target.position = Vector2(final_x, base_y)


func _on_tween_finished() -> void:
	finished.emit()
