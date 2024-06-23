class_name GDLinterIgnore
extends Resource

@export_group("Name Checks")
@export var _function_name: bool = false
@export var _class_name: bool = false
@export var _sub_class_name: bool = false
@export var _signal_name: bool = false
@export var _class_variable_name: bool = false
@export var _class_load_variable_name: bool = false
@export var _function_variable_name: bool = false
@export var _function_preload_variable_name: bool = false
@export var _function_argument_name: bool = false
@export var _loop_variable_name: bool = false
@export var _enum_name: bool = false
@export var _enum_element_name: bool = false
@export var _constant_name: bool = false
@export var _load_constant_name: bool = false

@export_group("Basic Checks")
@export var _duplicated_load: bool = false
@export var _expression_not_assigned: bool = false
@export var _unnecessary_pass: bool = false
@export var _unused_argument: bool = false
@export var _comparison_with_itself: bool = false

@export_group("Class Checks")
@export var _private_method_call: bool = false
@export var _class_definitions_order: bool = false

@export_group("Design Checks")
@export var _max_public_methods: bool = false
@export var _function_arguments_number: bool = false

@export_group("Format Checks")
@export var _max_file_lines: bool = false
@export var _trailing_whitespace: bool = false
@export var _max_line_length: bool = false
@export var _mixed_tabs_and_spaces: bool = false

@export_group("Misc Checks")
@export var _no_elif_return: bool = false
@export var _no_else_return: bool = false

