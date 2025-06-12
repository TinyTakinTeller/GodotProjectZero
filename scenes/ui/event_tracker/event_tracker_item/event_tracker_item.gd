class_name EventTrackerItem extends MarginContainer

var _event_data: EventData
var _vals: Array
var _index: int

@onready var line_label: Label = %LineLabel
@onready var event_label: LabelTyping = %EventLabel


func _ready() -> void:
	_connect_signals()


func set_content(event_data: EventData, vals: Array, index: int, type_out: bool) -> void:
	_event_data = event_data
	_vals = vals
	_index = index
	_on_display_language_updated()
	if type_out:
		play_typing_animation()


func _refresh_content() -> void:
	line_label.text = "[" + str(_index).pad_zeros(3) + "]"
	event_label.text = _event_data.get_text(_vals)
	if _event_data.color != Color.BLACK:
		modulate = _event_data.color


func play_typing_animation() -> void:
	event_label.play_typing_animation()


func _connect_signals() -> void:
	SignalBus.display_language_updated.connect(_on_display_language_updated)


func _on_display_language_updated() -> void:
	_refresh_content()
	match TranslationServer.get_locale():
		"en":
			event_label.autowrap_mode = TextServer.AutowrapMode.AUTOWRAP_WORD
		"fr":
			event_label.autowrap_mode = TextServer.AutowrapMode.AUTOWRAP_WORD
		"pt":
			event_label.autowrap_mode = TextServer.AutowrapMode.AUTOWRAP_WORD
		"pl":
			event_label.autowrap_mode = TextServer.AutowrapMode.AUTOWRAP_WORD
		"zh":
			event_label.autowrap_mode = TextServer.AutowrapMode.AUTOWRAP_ARBITRARY
		"th":
			event_label.autowrap_mode = TextServer.AutowrapMode.AUTOWRAP_WORD
		_:
			event_label.autowrap_mode = TextServer.AutowrapMode.AUTOWRAP_WORD
