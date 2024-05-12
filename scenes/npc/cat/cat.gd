extends Sprite2D

@onready var area_2d: Area2D = $Area2D
@onready var timer: Timer = $Timer


func _ready() -> void:
	_on_mouse_entered()
	area_2d.mouse_entered.connect(_on_mouse_entered)
	area_2d.mouse_exited.connect(_on_mouse_exited)
	timer.timeout.connect(_on_timeout)


func _on_mouse_entered() -> void:
	modulate.a = 0.00
	timer.start()


func _on_mouse_exited() -> void:
	pass


func _on_timeout() -> void:
	modulate.a = 0.02
