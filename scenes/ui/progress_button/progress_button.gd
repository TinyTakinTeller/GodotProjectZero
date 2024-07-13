class_name ProgressButton extends MarginContainer

const UNPAID_ANIMATION_LENGTH: float = 0.3

var _resource_generator: ResourceGenerator
var _disabled: bool = false

@onready var button: Button = %Button
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var progress_bar_simple_tween: SimpleTween = %ProgressBarSimpleTween
@onready var red_color_rect: ColorRect = %RedColorRect
@onready var red_color_rect_simple_tween: SimpleTween = %RedColorRectSimpleTween
@onready var new_unlock_tween: Node = %NewUnlockTween
@onready var line_effect: LineEffect = %LineEffect
@onready var label_effect_queue: Node2D = %LabelEffectQueue

###############
## overrides ##
###############


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		_propagate_theme_to_virtual_children()


func _ready() -> void:
	_display_defaults()
	_connect_signals()


###########
## setup ##
###########


func get_id() -> String:
	if _resource_generator == null:
		return ""
	return _resource_generator.id


func set_resource_generator(resource_generator: ResourceGenerator) -> void:
	_resource_generator = resource_generator


func display_resource_generator() -> void:
	visible = true
	_set_info()


###############
## animation ##
###############


func start_unlock_animation() -> void:
	new_unlock_tween.loop = true
	new_unlock_tween.play_animation()


func stop_unlock_animation() -> void:
	new_unlock_tween.loop = false


#############
## helpers ##
#############


func _display_defaults() -> void:
	visible = false
	_propagate_theme_to_virtual_children()


func _propagate_theme_to_virtual_children() -> void:
	var inherited_theme: Resource = NodeUtils.get_inherited_theme(self)
	if label_effect_queue != null:
		label_effect_queue.set_theme(inherited_theme)


func _set_info() -> void:
	button.text = _resource_generator.get_label()
	button.disabled = _disabled or _is_max_amount_reached()
	progress_bar.value = 0
	red_color_rect.modulate.a = 0


func _is_max_amount_reached() -> bool:
	return ResourceManager.is_max_amount_reached(get_id())


func _update_pivot() -> void:
	self.set_pivot_offset(Vector2(self.size.x / 2, self.size.y / 2))
	label_effect_queue.position.x = self.get_rect().size.x
	label_effect_queue.position.y = self.get_rect().size.y / 2


##############
## handlers ##
##############


func _handle_button_up() -> void:
	button.disabled = true
	SignalBus.progress_button_pressed.emit(_resource_generator)
	button.release_focus()


func _handle_button_down() -> void:
	if _resource_generator == null:
		return

	if _resource_generator.sfx_button_down:
		Audio.play_sfx(_resource_generator.id, _resource_generator.sfx_button_down)
	else:
		Audio.play_sfx_id("progress_button_down")


func _handle_resource_ui_updated(resource_tracker_item: ResourceTrackerItem, amount: int) -> void:
	if Game.PARAMS["debug_line_effect"]:
		line_effect.duration = _resource_generator.get_cooldown()
		line_effect.target_a = self
		line_effect.target_b = resource_tracker_item
		line_effect.play_animation()
	var text: String = resource_tracker_item._resource_generator.get_display_increment(amount)
	label_effect_queue.add_task(text)


#############
## signals ##
#############


func _connect_signals() -> void:
	self.resized.connect(_on_resized)
	button.button_up.connect(_on_button_up)
	button.button_down.connect(_on_button_down)
	button.mouse_entered.connect(_on_mouse_entered)
	button.mouse_exited.connect(_on_mouse_exited)
	progress_bar_simple_tween.animation_end.connect(_on_progress_bar_simple_tween_animation_end)
	red_color_rect_simple_tween.animation_end.connect(_on_red_color_rect_simple_tween_animation_end)
	SignalBus.progress_button_disabled.connect(_on_progress_button_disabled)
	SignalBus.progress_button_paid.connect(_on_progress_button_paid)
	SignalBus.progress_button_unpaid.connect(_on_progress_button_unpaid)
	SignalBus.resource_ui_updated.connect(_on_resource_ui_updated)
	SignalBus.offline_progress_processed.connect(_on_offline_progress_processed)


func _on_resized() -> void:
	_update_pivot()


## calling _on_mouse_entered() here because mobile users don't have mouse_entered signal
func _on_button_up() -> void:
	_on_mouse_entered()
	_handle_button_up()


func _on_button_down() -> void:
	_handle_button_down()


func _on_mouse_entered() -> void:
	SignalBus.progress_button_hover.emit(_resource_generator)
	stop_unlock_animation()


func _on_mouse_exited() -> void:
	SignalBus.progress_button_unhover.emit(_resource_generator)


func _on_progress_bar_simple_tween_animation_end() -> void:
	button.disabled = _disabled or _is_max_amount_reached()
	progress_bar.value = 0.0


func _on_red_color_rect_simple_tween_animation_end() -> void:
	button.disabled = _disabled or _is_max_amount_reached()


func _on_progress_button_disabled(id: String) -> void:
	if get_id() == id:
		_disabled = true
		button.disabled = true


func _on_progress_button_paid(resource_generator: ResourceGenerator) -> void:
	if _resource_generator == null:
		return

	if get_id() == resource_generator.id:
		progress_bar_simple_tween.play_animation_during(_resource_generator.get_cooldown())

		if _resource_generator.sfx_button_success:
			Audio.play_sfx(_resource_generator.id, _resource_generator.sfx_button_success)
		else:
			Audio.play_sfx_id("progress_button_success")


func _on_progress_button_unpaid(resource_generator: ResourceGenerator) -> void:
	if get_id() == resource_generator.id:
		red_color_rect_simple_tween.play_animation()

		Audio.play_sfx_id("progress_button_fail")


func _on_resource_ui_updated(
	resource_tracker_item: ResourceTrackerItem, _amount: int, change: int, source_id: String
) -> void:
	if get_id() != source_id:
		return
	if !is_visible_in_tree():
		return
	_handle_resource_ui_updated(resource_tracker_item, change)


func _on_offline_progress_processed(
	seconds_delta: int, _worker_progress: Dictionary, _enemy_progress: Dictionary, _factor: float
) -> void:
	_on_cooldown_skip(seconds_delta)


func _on_cooldown_skip(skip: float) -> void:
	progress_bar_simple_tween.progress_skip(skip)


############
## export ##
############


func _progress_bar_simple_tween_method(animation_percent: float) -> void:
	if _disabled:
		animation_percent = 1.0
	progress_bar.value = 1 - animation_percent


func _red_color_rect_simple_tween_method(animation_percent: float) -> void:
	red_color_rect.modulate.a = 1 - animation_percent


############
## static ##
############


static func before_than(a: ProgressButton, b: ProgressButton) -> bool:
	var sort_a: ResourceGenerator = Resources.resource_generators.get(a.get_id(), null)
	var sort_b: ResourceGenerator = Resources.resource_generators.get(b.get_id(), null)
	if sort_a == null:
		return true
	if sort_b == null:
		return false

	return sort_a.get_sort_value() < sort_b.get_sort_value()
