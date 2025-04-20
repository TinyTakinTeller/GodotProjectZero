class_name LabelParticleTween
extends Label
## This is a [Label] node that uses a [ParticleTween] tween.
## Contains [buffer] and [flush] methods to be compatible with a [SpawnerBuffer].
## [br][br]
## Original File MIT License Copyright (c) 2024 TinyTakinTeller

signal finished

var label_amount: int = 0
var label_title: String = ""

@onready var particle_tween: ParticleTween = $ParticleTween


func _ready() -> void:
	_connect_signals()

	# self.theme = Configuration.get_theme()


func buffer(new_label_amount: int, new_label_title: String) -> void:
	label_amount += new_label_amount
	label_title = new_label_title


func flush() -> void:
	self.text = "+%s %s" % [_format(label_amount), label_title]
	particle_tween.start()


func _connect_signals() -> void:
	particle_tween.finished.connect(_on_particle_tween_finished)


func _on_particle_tween_finished() -> void:
	finished.emit()


static func _format(amount: int) -> String:
	return NumberUtils.format_number_scientific(amount)
