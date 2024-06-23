@tool
extends MarginContainer

var _owner: GDLinterIgnoreWindow = owner

@onready var max_public_methods: CheckBox = %MaxPublicMethods
@onready var function_argument_number: CheckBox = %FunctionArgumentNumber


func init() -> void:
	_owner = owner
	max_public_methods.button_pressed = _owner.ignore.get("_max_public_methods")
	function_argument_number.button_pressed = _owner.ignore.get("_function_arguments_number")


func _on_max_public_methods_toggled(toggled_on: bool) -> void:
	_owner.ignore.set("_max_public_methods", toggled_on)


func _on_function_argument_number_toggled(toggled_on: bool) -> void:
	_owner.ignore.set("_function_arguments_number", toggled_on)
