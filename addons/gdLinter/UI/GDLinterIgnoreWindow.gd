@tool
class_name GDLinterIgnoreWindow
extends AcceptDialog

var ignore: GDLinterIgnore
var dock_ui: GDLinterDock

@onready var basic: MarginContainer = %Basic
@onready var design: MarginContainer = %Design
@onready var format: MarginContainer = %Format
@onready var misc: MarginContainer = %Misc
@onready var _name: MarginContainer = %Name
@onready var _class: MarginContainer = %Class


func reapply_linting() -> void:
	var current_script := EditorInterface.get_script_editor().get_current_script()
	dock_ui.gd_linter.script_editor.editor_script_changed.emit(current_script)


func _on_confirmed() -> void:
	reapply_linting()


func _on_about_to_popup() -> void:
	basic.init()
	design.init()
	format.init()
	misc.init()
	_name.init()
	_class.init()
