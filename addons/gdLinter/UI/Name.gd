@tool
extends MarginContainer

var _owner: GDLinterIgnoreWindow = owner

@onready var function_name: CheckBox = %FunctionName
@onready var sub_class_name: CheckBox = %SubClassName
@onready var signal_name: CheckBox = %SignalName
@onready var class_variable_name: CheckBox = %ClassVariableName
@onready var class_load_variable_name: CheckBox = %ClassLoadVariableName
@onready var function_variable_name: CheckBox = %FunctionVariableName
@onready var function_preload_variable_name: CheckBox = %FunctionPreloadVariableName
@onready var function_argument_name: CheckBox = %FunctionArgumentName
@onready var loop_variable_name: CheckBox = %LoopVariableName
@onready var enum_name: CheckBox = %EnumName
@onready var enum_element_name: CheckBox = %EnumElementName
@onready var constant_name: CheckBox = %ConstantName
@onready var load_constant_name: CheckBox = %LoadConstantName
@onready var _class_name: CheckBox = %ClassName


func init() -> void:
	_owner = owner
	function_name.button_pressed = _owner.ignore.get("_function_name")
	_class_name.button_pressed = _owner.ignore.get("_class_name")
	sub_class_name.button_pressed = _owner.ignore.get("_sub_class_name")
	signal_name.button_pressed = _owner.ignore.get("_signal_name")
	class_variable_name.button_pressed = _owner.ignore.get("_class_variable_name")
	class_load_variable_name.button_pressed = _owner.ignore.get("_class_load_variable_name")
	function_variable_name.button_pressed = _owner.ignore.get("_function_variable_name")
	function_preload_variable_name.button_pressed = _owner.ignore.get("_function_preload_variable_name")
	function_argument_name.button_pressed = _owner.ignore.get("_function_argument_name")
	loop_variable_name.button_pressed = _owner.ignore.get("_loop_variable_name")
	enum_name.button_pressed = _owner.ignore.get("_enum_name")
	enum_element_name.button_pressed = _owner.ignore.get("_enum_element_name")
	constant_name.button_pressed = _owner.ignore.get("_constant_name")
	load_constant_name.button_pressed = _owner.ignore.get("_load_constant_name")


func _on_function_name_toggled(toggled_on: bool) -> void:
	_owner.ignore.set("_function_name", toggled_on)


func _on_class_name_toggled(toggled_on: bool) -> void:
	_owner.ignore.set("_class_name", toggled_on)


func _on_sub_class_name_toggled(toggled_on: bool) -> void:
	_owner.ignore.set("_sub_class_name", toggled_on)


func _on_signal_name_toggled(toggled_on: bool) -> void:
	_owner.ignore.set("_signal_name", toggled_on)


func _on_class_variable_name_toggled(toggled_on: bool) -> void:
	_owner.ignore.set("_class_variable_name", toggled_on)


func _on_class_load_variable_name_toggled(toggled_on: bool) -> void:
	_owner.ignore.set("_class_load_variable_name", toggled_on)


func _on_function_variable_name_toggled(toggled_on: bool) -> void:
	_owner.ignore.set("_function_variable_name", toggled_on)


func _on_function_preload_variable_name_toggled(toggled_on: bool) -> void:
	_owner.ignore.set("_function_preload_variable_name", toggled_on)


func _on_function_argument_name_toggled(toggled_on: bool) -> void:
	_owner.ignore.set("_function_argument_name", toggled_on)


func _on_loop_variable_name_toggled(toggled_on: bool) -> void:
	_owner.ignore.set("_loop_variable_name", toggled_on)


func _on_enum_name_toggled(toggled_on: bool) -> void:
	_owner.ignore.set("_enum_name", toggled_on)


func _on_enum_element_name_toggled(toggled_on: bool) -> void:
	_owner.ignore.set("_enum_element_name", toggled_on)


func _on_constant_name_toggled(toggled_on: bool) -> void:
	_owner.ignore.set("_constant_name", toggled_on)


func _on_load_constant_name_toggled(toggled_on: bool) -> void:
	_owner.ignore.set("_load_constant_name", toggled_on)
