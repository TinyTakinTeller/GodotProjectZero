extends MarginContainer
class_name EventTrackerItem

const MIN_Y: int = -20
const MAX_Y: int = 400

@onready var line_label: Label = %LineLabel
@onready var event_label: Label = %EventLabel

var _event_data: EventData
var _vals: Array
var _index: int


func _ready() -> void:
	pass


func set_content(event_data: EventData, vals: Array, index: int) -> void:
	_event_data = event_data
	_vals = vals
	_index = index
	_refresh_content()


func _refresh_content() -> void:
	line_label.text = "[" + str(_index).pad_zeros(3) + "]"
	event_label.text = _event_data.get_text(_vals)
	if _event_data.color != Color.BLACK:
		modulate = _event_data.color
