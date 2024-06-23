@tool
extends MarginContainer

var _owner: GDLinterIgnoreWindow = owner

@onready var max_file_lines: CheckBox = %MaxFileLines
@onready var trailing_whitespace_check_box: CheckBox = %TrailingWhitespaceCheckBox
@onready var max_line_length: CheckBox = %MaxLineLength
@onready var mixed_tabs_and_spaces: CheckBox = %MixedTabsAndSpaces


func init() -> void:
	_owner = owner
	max_file_lines.button_pressed = _owner.ignore.get("_max_file_lines")
	trailing_whitespace_check_box.button_pressed = _owner.ignore.get("_trailing_whitespace")
	max_line_length.button_pressed = _owner.ignore.get("_max_line_length")
	mixed_tabs_and_spaces.button_pressed = _owner.ignore.get("_mixed_tabs_and_spaces")


func _on_max_file_lines_toggled(toggled_on: bool) -> void:
	_owner.ignore.set("_max_file_lines", toggled_on)


func _on_trailing_whitespace_check_box_toggled(toggled_on: bool) -> void:
	_owner.ignore.set("_trailing_whitespace", toggled_on)


func _on_max_line_length_toggled(toggled_on: bool) -> void:
	_owner.ignore.set("_max_line_length", toggled_on)


func _on_mixed_tabs_and_spaces_toggled(toggled_on: bool) -> void:
	_owner.ignore.set("_mixed_tabs_and_spaces", toggled_on)
