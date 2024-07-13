class_name SaveFileItemSection
extends MarginContainer

signal new_input_set(new_text: String, old_text: String)

var _input_enabled: bool = false
var _input_text: String = ""
var _previous_input_text: String = ""

@onready var title_label: Label = %TitleLabel
@onready var value_label: Label = %ValueLabel
@onready var input_margin_container: MarginContainer = %InputMarginContainer
@onready var line_edit: LineEdit = %LineEdit
@onready var scroll_container: ScrollContainer = %ScrollContainer

###############
## overrides ##
###############


func _ready() -> void:
	_initialize()
	_connect_signals()


###########
## setup ##
###########


func get_input_text() -> String:
	return _input_text


func set_labels(title_text: String, value_text: String, input: bool = false) -> void:
	_input_enabled = input
	_set_title_label(title_text)
	_set_value_label(value_text)


#############
## helpers ##
#############


func _initialize() -> void:
	set_focus_mode(FOCUS_CLICK)
	_set_input_label("Title")
	_set_value_label("value")
	line_edit.max_length = Game.params["max_file_name_length"]
	ScrollContainerUtils.disable_scrollbars(scroll_container)


func _set_title_label(text: String) -> void:
	title_label.text = text


func _set_value_label(text: String = "") -> void:
	if StringUtils.is_not_empty(text):
		_input_text = text
		_previous_input_text = _input_text
	value_label.text = _input_text
	value_label.visible = true
	input_margin_container.visible = false
	title_label.visible = true


func _set_input_label(text: String = "") -> void:
	if StringUtils.is_not_empty(text):
		_input_text = text
		_previous_input_text = _input_text
	line_edit.text = _input_text
	input_margin_container.visible = true
	value_label.visible = false
	title_label.visible = false
	line_edit.grab_focus()


#############
## signals ##
#############


func _connect_signals() -> void:
	line_edit.text_changed.connect(_on_text_changed)
	line_edit.focus_exited.connect(_on_focus_exited)
	self.mouse_entered.connect(_on_mouse_entered)


func _on_text_changed(new_text: String) -> void:
	_input_text = new_text


func _on_focus_exited() -> void:
	if _input_text != _previous_input_text:
		new_input_set.emit(_input_text, _previous_input_text)
		_previous_input_text = _input_text
	_set_value_label()


func _on_mouse_entered() -> void:
	if _input_enabled:
		_set_input_label()
	else:
		grab_focus()
