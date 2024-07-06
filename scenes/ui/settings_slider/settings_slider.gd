class_name SettingsSlider extends MarginContainer

signal data_changed(toggle: bool, value: float)

var _toggle: bool
var _value: float

@onready var toggle_button: Button = %ToggleButton
@onready var title_label: Label = %TitleLabel
@onready var value_label: Label = %ValueLabel
@onready var dec_button: Button = %DecButton
@onready var h_slider: HSlider = %HSlider
@onready var inc_button: Button = %IncButton

###############
## overrides ##
###############


func _ready() -> void:
	_initialize()
	_connect_signals()


#############
## methods ##
#############


func set_data(toggle: bool, value: float) -> void:
	_toggle = toggle
	_value = value
	_update_ui()


#############
## helpers ##
#############


func _initialize() -> void:
	_toggle = true
	_value = 1.0
	_update_ui(false)


func _update_toggle_ui(user_input: bool = true) -> void:
	toggle_button.text = "On" if _toggle else "Off"

	if user_input:
		data_changed.emit(_toggle, _value)


func _update_value_ui(user_input: bool = true) -> void:
	h_slider.value = _value
	value_label.text = str(int(h_slider.value * 100.0))

	if user_input:
		data_changed.emit(_toggle, _value)


func _update_ui(user_input: bool = true) -> void:
	_update_toggle_ui(user_input)
	_update_value_ui(user_input)


#############
## signals ##
#############


func _connect_signals() -> void:
	toggle_button.button_up.connect(_on_toggle_button_button_up)
	dec_button.button_up.connect(_on_dec_button_button_up)
	inc_button.button_up.connect(_on_inc_button_button_up)
	h_slider.value_changed.connect(_on_h_slider_value_changed)


func _on_mouse_release(node: Control) -> void:
	node.release_focus()


func _on_toggle_button_button_up() -> void:
	_on_mouse_release(toggle_button)
	_toggle = not _toggle
	_update_toggle_ui()


func _on_dec_button_button_up() -> void:
	_on_mouse_release(dec_button)
	_value = max(0, _value - 0.01)
	_update_value_ui()


func _on_inc_button_button_up() -> void:
	_on_mouse_release(inc_button)
	_value = min(1.0, _value + 0.01)
	_update_value_ui()


func _on_h_slider_value_changed(value: float) -> void:
	_on_mouse_release(h_slider)
	_value = value
	_update_value_ui()
