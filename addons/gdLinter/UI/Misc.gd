@tool
extends MarginContainer

var _owner: GDLinterIgnoreWindow = owner

@onready var no_elif_return: CheckBox = %NoElifReturn
@onready var no_else_return: CheckBox = %NoElseReturn


func init() -> void:
	_owner = owner
	no_elif_return.button_pressed = _owner.ignore.get("_no_elif_return")
	no_else_return.button_pressed = _owner.ignore.get("_no_else_return")


func _on_no_elif_return_toggled(toggled_on: bool) -> void:
	_owner.ignore.set("_no_elif_return", toggled_on)


func _on_no_else_return_toggled(toggled_on: bool) -> void:
	_owner.ignore.set("_no_else_return", toggled_on)
