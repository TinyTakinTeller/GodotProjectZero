class_name LanguageButton
extends MarginContainer

signal clicked(value: String)

var locale: String

@onready var button: Button = $Button
@onready var texture_rect: TextureRect = $TextureRect


func _ready() -> void:
	set_vars()
	_connect_signals()


func set_vars() -> void:
	locale = ""


func _connect_signals() -> void:
	button.button_up.connect(_on_button_up)


func _on_button_up() -> void:
	clicked.emit(locale)
