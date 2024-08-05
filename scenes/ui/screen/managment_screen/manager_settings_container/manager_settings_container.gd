class_name ManagerSettingsContainer
extends MarginContainer

const MAX_SCALE_BUTTONS: int = 11

@export var scale_button_scene: PackedScene

var min_scale: int = 1
var max_scale: int = 0

@onready var h_box_container: HBoxContainer = %HBoxContainer

###############
## overrides ##
###############


func _ready() -> void:
	_initialize()
	_connect_signals()


#############
## helpers ##
#############


func _initialize() -> void:
	var scale_value: int = SaveFile.get_settings_population_scale()
	_clear_items()
	max_scale = max(1, ArrayUtils.max_element(SaveFile.workers.values() + [0]))
	var button_scale: int = min_scale
	var padding: int = MAX_SCALE_BUTTONS
	while max_scale > PowUtils.pow_int(10, padding):
		padding += 1
		button_scale *= 10
	while button_scale <= max_scale and h_box_container.get_child_count() < MAX_SCALE_BUTTONS:
		_add_scale_button(button_scale, scale_value)
		button_scale *= 10


func _add_scale_button(button_scale: int, active_scale: int) -> ScaleButton:
	var scale_button: ScaleButton = scale_button_scene.instantiate() as ScaleButton
	NodeUtils.add_child(scale_button, h_box_container)

	var button: Button = scale_button.button
	_connect_signal(button, button_scale)
	button.text = NumberUtils.format_number_scientific(button_scale, 0)
	if button_scale == active_scale:
		button.disabled = true
	else:
		button.disabled = false

	return scale_button


func _clear_items() -> void:
	NodeUtils.clear_children(h_box_container)


#############
## handler ##
#############


func _handle_on_worker_updated(total: int) -> void:
	if total > max_scale:
		var count: int = h_box_container.get_child_count()
		var exponent: int = max(0, count - 1)
		if total > PowUtils.pow_int(10, exponent):
			_initialize()
		max_scale = total


func _handle_on_scale_button_up(button: Button, scale_value: int) -> void:
	button.disabled = true
	SignalBus.toggle_scale_pressed.emit(scale_value)
	button.release_focus()
	for scale_button: ScaleButton in h_box_container.get_children():
		var other_button: Button = scale_button.button
		if other_button.text != button.text:
			other_button.disabled = false

	Audio.play_sfx_id("generic_click")


func _handle_on_scale_button_hover(scale_value: int) -> void:
	var title: String = "[%s]" % NumberUtils.format_number(scale_value)
	var info: String = Locale.get_scale_settings_info(scale_value)
	SignalBus.info_hover.emit(title, info)


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.worker_updated.connect(_on_worker_updated)


func _connect_signal(button: Button, scale_value: int) -> void:
	button.button_up.connect(_on_scale_button_up.bind(button, scale_value))
	button.button_down.connect(_on_scale_button_down.bind(button))
	button.mouse_entered.connect(_on_scale_button_hover.bind(scale_value))


func _on_worker_updated(_id: String, total: int, _amount: int) -> void:
	_handle_on_worker_updated(total)


func _on_scale_button_up(button: Button, scale_value: int) -> void:
	_handle_on_scale_button_hover(scale_value)
	_handle_on_scale_button_up(button, scale_value)


func _on_scale_button_down(button: Button) -> void:
	button.release_focus()


func _on_scale_button_hover(scale_value: int) -> void:
	_handle_on_scale_button_hover(scale_value)
