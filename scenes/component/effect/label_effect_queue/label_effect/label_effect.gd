extends Node2D
class_name LabelEffect

signal task_finished(text: String)

@onready var sub_viewport: SubViewport = $SubViewport
@onready var label: Label = $SubViewport/Label
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D

var finished: bool = true
var task: String


func _process(_delta: float) -> void:
	if !is_visible_in_tree():
		stop()


func _ready() -> void:
	gpu_particles_2d.one_shot = true
	gpu_particles_2d.emitting = false
	gpu_particles_2d.finished.connect(_on_finished)


func restart(text: String) -> void:
	task = text
	finished = false
	label.text = text
	label.visible = true
	gpu_particles_2d.emitting = true
	gpu_particles_2d.restart()


func stop() -> void:
	gpu_particles_2d.emitting = false
	label.visible = false


func set_theme(theme: Resource) -> void:
	label.theme = theme


func _on_finished() -> void:
	task_finished.emit(task)
	finished = true
