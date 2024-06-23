@tool
class_name GDLinterDock
extends Control

var gd_linter: GDLinter
var error_descriptions := preload("res://addons/gdLinter/error_descriptions.gd").new()
var script_text_editor: ScriptEditorBase
var color_error: Color = EditorInterface.get_editor_settings()\
		.get_setting("text_editor/theme/highlighting/comment_markers/critical_color")

var num_problems: int = 0
var num_ignored_problems: int = 0

var _ignore: GDLinterIgnore = preload("res://addons/gdLinter/Settings/ignore.tres")

@onready var file: Label = %File
@onready var problems_num: Label = %ProblemsNum
@onready var ignored_problems_num: Label = %IgnoredProblemsNum
@onready var version: Label = %Version
@onready var tree: Tree = %Tree
@onready var gd_linter_ignore_window: GDLinterIgnoreWindow = $GdLinterIgnoreWindow


func _ready() -> void:
	gd_linter_ignore_window.ignore = _ignore
	gd_linter_ignore_window.dock_ui = self
	tree.add_theme_color_override("font_color", color_error)
	tree.set_column_title(0, "Line")
	tree.set_column_title(1, "Error")
	tree.set_column_title_alignment(0, HORIZONTAL_ALIGNMENT_LEFT)
	tree.set_column_title_alignment(1, HORIZONTAL_ALIGNMENT_LEFT)
	tree.set_column_custom_minimum_width(0, 75)
	tree.set_column_custom_minimum_width(1, 0)
	tree.set_column_expand(0, false)
	tree.set_column_expand(1, true)
	tree.set_column_clip_content(0, false)
	tree.set_column_clip_content(1, true)
	tree.set_column_expand_ratio(0, 4)
	tree.item_activated.connect(_on_item_activated)

func reset_problem_num() -> void:
	num_problems = 0
	num_ignored_problems = 0


func create_item(line: int, name: String) -> void:
	var regex = RegEx.new()
	regex.compile("(?<=\\()[^\\)]+")
	var result := regex.search_all(name)
	var error_type := result[-1].strings[0]
	if _ignore.get(str_dash_to_underscore(error_type)):
		num_ignored_problems += 1
		return
	
	var item := tree.create_item()
	item.set_text(0, str(line))
	item.set_text(1, name)
	item.set_metadata(0, line)
	
	if error_descriptions.error.has(error_type):
		item.set_tooltip_text(1, error_descriptions.error[error_type])
	num_problems += 1


func set_problems_label(number: int) -> void:
	problems_num.text = str(number)


func set_ignored_problems_label(number: int) -> void:
	ignored_problems_num.text = str(number)

func clear_items() -> void:
	reset_problem_num()
	tree.clear()
	tree.create_item()


func _on_item_activated() -> void:
	var selected: TreeItem = tree.get_selected()
	var line := selected.get_metadata(0)
	
	EditorInterface.edit_script(load(file.text), line)

	if not EditorInterface.get_editor_settings().get("text_editor/external/use_external_editor"):
		EditorInterface.set_main_screen_editor("Script")


func str_dash_to_underscore(string: String) -> String:
	return "_" + string.replace("-", "_")


func is_error_ignored(name: String) -> bool:
	var regex = RegEx.new()
	regex.compile("(?<=\\()[^\\)]+")
	var result := regex.search_all(name)
	var error_type := result[-1].strings[0]
	return _ignore.get(str_dash_to_underscore(error_type))


func _on_button_pressed() -> void:
	gd_linter_ignore_window.popup()
