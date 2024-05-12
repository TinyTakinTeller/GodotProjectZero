extends MarginContainer
class_name EventTrackerItem

@onready var line_label: Label = %LineLabel
@onready var event_label: Label = %EventLabel
@onready var typing_text_tween: Node = %TypingTextTween

var _event_data: EventData
var _vals: Array
var _index: int


func _ready() -> void:
	pass


func set_content(event_data: EventData, vals: Array, index: int, type_out: bool) -> void:
	_event_data = event_data
	_vals = vals
	_index = index
	_refresh_content()
	if type_out:
		play_typing_animation()


func _refresh_content() -> void:
	line_label.text = "[" + str(_index).pad_zeros(3) + "]"
	event_label.text = _event_data.get_text(_vals)
	if _event_data.color != Color.BLACK:
		modulate = _event_data.color


func play_typing_animation() -> void:
	var animation_length: float = event_label.text.length() * Game.params["animation_speed_diary"]
	typing_text_tween.play_animation(animation_length)
