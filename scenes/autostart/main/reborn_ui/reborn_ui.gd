class_name RebornUI
extends Control

const FORCE_CLEAR: bool = true

@export var label_typing_scene: PackedScene

var _index: int = 0
var _text: String = ""
var _is_last_text: bool = false

@onready var label_v_box_container: VBoxContainer = %LabelVBoxContainer
@onready var button: Button = %Button

###############
## overrides ##
###############


func _ready() -> void:
	_initialize()
	_connect_signals()


#############
## methods ##
#############


func push_next_label() -> void:
	if FORCE_CLEAR:
		NodeUtils.clear_children_of(label_v_box_container, LabelTyping)

	var reborn: int = SaveFile.substances.get("heart", 0) + 1

	_index += 1
	var key: String = "reborn_" + str(reborn) + "_line_" + str(_index)
	_text = Locale.get_ui_label(key)
	if StringUtils.is_empty(_text) and not _is_last_text:
		_text = "..."
		_is_last_text = true
	if not _is_last_text:
		var next_key: String = "reborn_" + str(reborn) + "_line_" + str(_index + 1)
		var next_text: String = Locale.get_ui_label(next_key)
		if StringUtils.is_empty(next_text):
			_is_last_text = true

	button.visible = true
	if _text == " ":
		_on_typing_animation_end()
	elif StringUtils.is_not_empty(_text) and not _text == "?":
		_add_label_typing(_text)
	else:
		SignalBus.prestige_reborn.emit()


#############
## helpers ##
#############


func _initialize() -> void:
	button.text = "?"
	button.visible = false
	button.disabled = true
	NodeUtils.clear_children_of(label_v_box_container, LabelTyping)


func _add_label_typing(text: String) -> void:
	var label_typing: LabelTyping = label_typing_scene.instantiate() as LabelTyping
	NodeUtils.add_child(label_typing, label_v_box_container)
	label_typing.text = text
	label_typing.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_typing.autowrap_mode = TextServer.AUTOWRAP_OFF

	Audio.play_sfx_id("cat_talking", 0.0)

	label_typing.typing_animation_end.connect(_on_typing_animation_end)
	label_typing.play_typing_animation()


#############
## signals ##
#############


func _on_typing_animation_end() -> void:
	Audio.stop_sfx_id("cat_talking")

	button.release_focus()
	button.disabled = false

	if _text == " ":
		NodeUtils.clear_children_of(label_v_box_container, LabelTyping)
		_on_button_up()


func _connect_signals() -> void:
	button.button_up.connect(_on_button_up)


func _on_button_up() -> void:
	# Audio.play_sfx_id("generic_click")

	button.release_focus()
	button.disabled = true
	push_next_label()
