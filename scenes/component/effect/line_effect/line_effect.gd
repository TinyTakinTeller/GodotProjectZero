extends Line2D
class_name LineEffect

@export var max_alpha: float = 1.0
@export var duration: float = 1.0
@export var color: Color = Color(1, 1, 1, 1)
@export var line_width: int = 1
@export var target_a: Node
@export var target_b: Node
@export var offset_a_x: int = 0
@export var offset_b_x: int = 0

var _tween: Tween
var _alpha: float = 0.0


func play_animation() -> void:
	_prepare_animation()
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_method(_tween_method, 0.0, max_alpha, duration)
	_tween.tween_callback(_on_animation_end)


func _target_animation() -> void:
	var a: Vector2 = to_local(target_a.get_screen_position())
	var b: Vector2 = to_local(target_b.get_screen_position())
	a.x += target_a.get_rect().size.x
	a.y += target_a.get_rect().size.y / 2
	b.y += target_b.get_rect().size.y / 2
	a.x += offset_a_x
	b.x += offset_b_x
	self.set_points([a, b])


func _prepare_animation() -> void:
	_target_animation()
	_alpha = max_alpha
	self.set_width(line_width)
	visible = true


func _tween_method(animation_percent: float) -> void:
	_alpha = max_alpha - animation_percent
	color.a = _alpha
	self.set_default_color(color)
	_target_animation()


func _on_animation_end() -> void:
	visible = false
