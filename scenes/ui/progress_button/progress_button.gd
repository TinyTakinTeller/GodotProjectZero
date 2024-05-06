extends MarginContainer
class_name ProgressButton

const UNPAID_ANIMATION_LENGTH: float = 0.3

@onready var button: Button = %Button
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var red_color_rect: ColorRect = %RedColorRect
@onready var new_unlock_tween: Node = %NewUnlockTween

@export var _resource_generator: ResourceGenerator


func _ready() -> void:
	visible = false
	button.button_up.connect(_on_button_up)
	button.mouse_entered.connect(_on_mouse_entered)
	SignalBus.progress_button_paid.connect(_on_progress_button_paid)
	SignalBus.progress_button_unpaid.connect(_on_progress_button_unpaid)


func _setup() -> void:
	button.text = _resource_generator.get_label()
	button.disabled = false
	progress_bar.value = 0
	red_color_rect.modulate.a = 0
	self.set_pivot_offset(Vector2(self.size.x / 2, self.size.y / 2))
	visible = true


func set_resource_generator(resource_generator: ResourceGenerator) -> void:
	_resource_generator = resource_generator
	_setup()


func start_unlock_animation() -> void:
	new_unlock_tween.loop = true
	new_unlock_tween.play_animation()


func stop_unlock_animation() -> void:
	new_unlock_tween.loop = false


func _handle_button_up() -> void:
	button.disabled = true
	SignalBus.progress_button_pressed.emit(_resource_generator)
	button.release_focus()


func _play_cooldown_animation() -> void:
	var tween: Tween = self.create_tween()
	tween.tween_method(_cooldown_tween_method, 0.0, 1.0, _resource_generator.get_cooldown())
	tween.tween_callback(self._on_cooldown_animation_end)


func _cooldown_tween_method(animation_percent: float) -> void:
	progress_bar.value = 1 - animation_percent


func _on_cooldown_animation_end() -> void:
	button.disabled = false


func _play_unpaid_animation() -> void:
	var tween: Tween = self.create_tween()
	tween.tween_method(_unpaid_tween_method, 0.0, 1.0, UNPAID_ANIMATION_LENGTH)
	tween.tween_callback(self._on_unpaid_animation_end)


func _unpaid_tween_method(animation_percent: float) -> void:
	red_color_rect.modulate.a = 1 - animation_percent


func _on_unpaid_animation_end() -> void:
	button.disabled = false


func _on_progress_button_paid(resource_generator: ResourceGenerator) -> void:
	if _resource_generator.id != resource_generator.id:
		return
	_play_cooldown_animation()


func _on_progress_button_unpaid(resource_generator: ResourceGenerator) -> void:
	if _resource_generator.id != resource_generator.id:
		return
	_play_unpaid_animation()


func _on_button_up() -> void:
	_handle_button_up()


func _on_mouse_entered() -> void:
	SignalBus.progress_button_hover.emit(_resource_generator)
	stop_unlock_animation()
