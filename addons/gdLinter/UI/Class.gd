@tool
extends MarginContainer

var _owner: GDLinterIgnoreWindow = owner

@onready var private_method_call: CheckBox = %PrivateMethodCall
@onready var class_definition_order: CheckBox = %ClassDefinitionOrder


func init() -> void:
	_owner = owner
	private_method_call.button_pressed = _owner.ignore.get("_private_method_call")
	class_definition_order.button_pressed = _owner.ignore.get("_class_definitions_order")


func _on_private_method_call_toggled(toggled_on: bool) -> void:
	_owner.ignore.set("_private_method_call", toggled_on)


func _on_class_definition_order_toggled(toggled_on: bool) -> void:
	_owner.ignore.set("_class_definitions_order", toggled_on)
