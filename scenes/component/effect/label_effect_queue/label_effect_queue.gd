extends Node2D

@onready var queue: Node2D = %Queue
@onready var timer: Timer = $Timer

@export var label_effect_scene: PackedScene
@export var delay: float = 0.5

var _theme: Resource
var _tasks: Array[String] = []
var _last_task: String = ""


func _ready() -> void:
	set_delay(delay)
	_extend_queue()
	timer.timeout.connect(_on_timer_timeout)


func set_delay(new_delay: float) -> void:
	delay = new_delay
	timer.wait_time = delay


func set_theme(theme: Resource) -> void:
	_theme = theme
	for label_effect: LabelEffect in queue.get_children():
		label_effect.set_theme(_theme)


func add_task(text: String) -> void:
	if _last_task == "":
		_last_task = text
		trigger_label_effect(text)
		timer.start(delay)
	else:
		_tasks.append(text)


func trigger_label_effect(text: String) -> void:
	for label_effect: LabelEffect in queue.get_children():
		if label_effect.finished:
			_restart(label_effect, text)
			return
	var new_label_effect: LabelEffect = _extend_queue()
	_restart(new_label_effect, text)


func _restart(label_effect: LabelEffect, text: String) -> void:
	label_effect.restart(text)


func _extend_queue() -> LabelEffect:
	var label_effect: LabelEffect = label_effect_scene.instantiate()
	queue.add_child(label_effect)
	label_effect.task_finished.connect(_on_task_finished)
	label_effect.set_theme(_theme)
	return label_effect


func _on_timer_timeout() -> void:
	if _tasks.is_empty():
		_last_task = ""
		return
	var task: String = _tasks.pop_front()
	_last_task = task
	trigger_label_effect(task)


func _on_task_finished(_task: String) -> void:
	pass
