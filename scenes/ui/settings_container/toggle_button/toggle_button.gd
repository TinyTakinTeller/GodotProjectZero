extends MarginContainer

@export var _id: String
@export var _toggle_ids: Array[String] = []
@export var _toggle_id_index: int = -1

@onready var button: Button = %Button


func _ready() -> void:
	button.button_up.connect(_on_button_up)


func toggle() -> void:
	if _toggle_ids.size() == 0:
		return
	_toggle_id_index = (_toggle_id_index + 1) % _toggle_ids.size()
	var toggle_id: String = _toggle_ids[_toggle_id_index]
	button.text = toggle_id
	SignalBus.toggle_button_pressed.emit(_id, toggle_id)
	button.release_focus()


func set_from_toggle_id(toggle_id: String) -> void:
	_toggle_id_index = _toggle_ids.find(toggle_id) - 1


func _on_button_up() -> void:
	toggle()
