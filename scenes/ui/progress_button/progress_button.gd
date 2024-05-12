extends MarginContainer
class_name ProgressButton

const UNPAID_ANIMATION_LENGTH: float = 0.3

@onready var button: Button = %Button
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var progress_bar_simple_tween: SimpleTween = %ProgressBarSimpleTween
@onready var red_color_rect: ColorRect = %RedColorRect
@onready var red_color_rect_simple_tween: SimpleTween = %RedColorRectSimpleTween
@onready var new_unlock_tween: Node = %NewUnlockTween
@onready var line_effect: LineEffect = %LineEffect
@onready var label_effect_queue: Node2D = %LabelEffectQueue

@export var _resource_generator: ResourceGenerator

var _disabled: bool = false


func _propagate_theme_to_children() -> void:
	var inherited_theme: Resource = NodeUtils.get_inherited_theme(self)
	if label_effect_queue != null:
		label_effect_queue.set_theme(inherited_theme)


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		_propagate_theme_to_children()


func _ready() -> void:
	visible = false
	_propagate_theme_to_children()
	button.button_up.connect(_on_button_up)
	button.mouse_entered.connect(_on_mouse_entered)
	button.mouse_exited.connect(_on_mouse_exited)
	progress_bar_simple_tween.end.connect(_on_cooldown_animation_end)
	red_color_rect_simple_tween.end.connect(_on_red_color_rect_simple_tween)
	SignalBus.progress_button_paid.connect(_on_progress_button_paid)
	SignalBus.progress_button_unpaid.connect(_on_progress_button_unpaid)
	SignalBus.progress_button_disabled.connect(_on_progress_button_disabled)
	SignalBus.resource_ui_updated.connect(_on_resource_ui_updated)


func get_id() -> String:
	return _resource_generator.id


func display_resource_generator() -> void:
	button.text = _resource_generator.get_label()
	button.disabled = _disabled or _is_max_amount_reached()
	progress_bar.value = 0
	red_color_rect.modulate.a = 0
	self.set_pivot_offset(Vector2(self.size.x / 2, self.size.y / 2))
	visible = true
	label_effect_queue.position.x += self.get_rect().size.x
	label_effect_queue.position.y += self.get_rect().size.y / 2


func set_resource_generator(resource_generator: ResourceGenerator) -> void:
	_resource_generator = resource_generator


func start_unlock_animation() -> void:
	new_unlock_tween.loop = true
	new_unlock_tween.play_animation()


func stop_unlock_animation() -> void:
	new_unlock_tween.loop = false


func _handle_button_up() -> void:
	button.disabled = true
	SignalBus.progress_button_pressed.emit(_resource_generator)
	button.release_focus()


func _cooldown_tween_method(animation_percent: float) -> void:
	if _disabled:
		animation_percent = 1.0
	progress_bar.value = 1 - animation_percent


func _on_cooldown_animation_end() -> void:
	button.disabled = _disabled or _is_max_amount_reached()


func _red_color_rect_simple_tween_method(animation_percent: float) -> void:
	red_color_rect.modulate.a = 1 - animation_percent


func _on_red_color_rect_simple_tween() -> void:
	button.disabled = _disabled or _is_max_amount_reached()


func _is_max_amount_reached() -> bool:
	return ResourceManager.is_max_amount_reached(get_id())


func _on_resource_ui_updated(
	resource_tracker_item: ResourceTrackerItem, _amount: int, change: int, source_id: String
) -> void:
	if get_id() != source_id:
		return
	if Game.params["debug_line_effect"]:
		line_effect.duration = _resource_generator.get_cooldown()
		line_effect.target_a = self
		line_effect.target_b = resource_tracker_item
		line_effect.play_animation()
	var text: String = resource_tracker_item._resource_generator.get_display_increment(change)
	label_effect_queue.add_task(text)


func _on_progress_button_disabled(id: String) -> void:
	if get_id() != id:
		return
	_disabled = true
	button.disabled = true


func _on_progress_button_paid(resource_generator: ResourceGenerator) -> void:
	if get_id() != resource_generator.id:
		return
	progress_bar_simple_tween.play_animation_(_resource_generator.get_cooldown())


func _on_progress_button_unpaid(resource_generator: ResourceGenerator) -> void:
	if get_id() != resource_generator.id:
		return
	red_color_rect_simple_tween.play_animation()


func _on_button_up() -> void:
	_handle_button_up()


func _on_mouse_entered() -> void:
	SignalBus.progress_button_hover.emit(_resource_generator)
	stop_unlock_animation()


func _on_mouse_exited() -> void:
	SignalBus.progress_button_unhover.emit(_resource_generator)


static func before_than(a: ProgressButton, b: ProgressButton) -> bool:
	var sort_a: ResourceGenerator = Resources.resource_generators.get(a.get_id(), null)
	var sort_b: ResourceGenerator = Resources.resource_generators.get(b.get_id(), null)
	if sort_a == null:
		return true
	if sort_b == null:
		return false
	return sort_a.sort_value < sort_b.sort_value
