extends MarginContainer
class_name EventTrackerItem

const MIN_Y: int = -20
const MAX_Y: int = 400

@onready var line_label: Label = %LineLabel
@onready var event_label: Label = %EventLabel

var _content: String
var _index: int


func _ready() -> void:
	pass


func set_content(content: String, index: int) -> void:
	_content = content
	_index = index
	line_label.text = "[" + str(_index).pad_zeros(3) + "]"
	event_label.text = content
