@tool
extends MarginContainer

var _owner: GDLinterIgnoreWindow = owner

@onready var duplicated_load: CheckBox = %DuplicatedLoad
@onready var expression_not_assigned: CheckBox = %ExpressionNotAssigned
@onready var unnecessary_pass: CheckBox = %UnnecessaryPass
@onready var unused_argument: CheckBox = %UnusedArgument
@onready var comparision_with_itself: CheckBox = %ComparisionWithItself


func init() -> void:
	_owner = owner
	duplicated_load.button_pressed = _owner.ignore.get("_duplicated_load")
	expression_not_assigned.button_pressed = _owner.ignore.get("_expression_not_assigned")
	unnecessary_pass.button_pressed = _owner.ignore.get("_unnecessary_pass")
	unused_argument.button_pressed = _owner.ignore.get("_unused_argument")
	comparision_with_itself.button_pressed = _owner.ignore.get("_comparison_with_itself")


func _on_duplicated_load_toggled(toggled_on: bool) -> void:
	_owner.ignore.set("_duplicated_load", toggled_on)


func _on_expression_not_assigned_toggled(toggled_on: bool) -> void:
	_owner.ignore.set("_expression_not_assigned", toggled_on)


func _on_unnecessary_pass_toggled(toggled_on: bool) -> void:
	_owner.ignore.set("_unnecessary_pass", toggled_on)


func _on_unused_argument_toggled(toggled_on: bool) -> void:
	_owner.ignore.set("_unused_argument", toggled_on)


func _on_comparision_with_itself_toggled(toggled_on: bool) -> void:
	_owner.ignore.set("_comparison_with_itself", toggled_on)
