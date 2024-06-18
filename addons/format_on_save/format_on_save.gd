@tool
class_name FormatOnSave extends EditorPlugin

const SUCCESS: int = 0
const AUTO_RELOAD_SETTING: String = "text_editor/behavior/files/auto_reload_scripts_on_external_change"
var original_auto_reload_setting: bool


# LIFECYCLE EVENTS
func _enter_tree():
	activate_auto_reload_setting()
	resource_saved.connect(on_resource_saved)


func _exit_tree():
	resource_saved.disconnect(on_resource_saved)
	restore_original_auto_reload_setting()


# CALLED WHEN A SCRIPT IS SAVED
func on_resource_saved(resource: Resource):
	if resource is Script:
		var script: Script = resource
		var current_script = get_editor_interface().get_script_editor().get_current_script()
		var text_edit: CodeEdit = (
			get_editor_interface().get_script_editor().get_current_editor().get_base_editor()
		)

		# Prevents other unsaved scripts from overwriting the active one
		if current_script == script:
			var filepath: String = ProjectSettings.globalize_path(resource.resource_path)

			# Run gdformat
			var exit_code = OS.execute("gdformat", [filepath])

			# Replace source_code with formatted source_code
			if exit_code == SUCCESS:
				var formatted_source = FileAccess.get_file_as_string(resource.resource_path)
				FormatOnSave.reload_script(text_edit, formatted_source)


# Workaround until this PR is merged:
# https://github.com/godotengine/godot/pull/83267
# Thanks, @KANAjetzt 💖
static func reload_script(text_edit: TextEdit, source_code: String) -> void:
	var column := text_edit.get_caret_column()
	var row := text_edit.get_caret_line()
	var scroll_position_h := text_edit.get_h_scroll_bar().value
	var scroll_position_v := text_edit.get_v_scroll_bar().value

	text_edit.text = source_code
	text_edit.set_caret_column(column)
	text_edit.set_caret_line(row)
	text_edit.scroll_horizontal = scroll_position_h
	text_edit.scroll_vertical = scroll_position_v

	text_edit.tag_saved_version()


# For this workaround to work, we need to disable the "Reload/Resave" pop-up
func activate_auto_reload_setting():
	var settings := get_editor_interface().get_editor_settings()
	original_auto_reload_setting = settings.get(AUTO_RELOAD_SETTING)
	settings.set(AUTO_RELOAD_SETTING, true)


# If the plugin is disabled, let's attempt to restore the original editor setting
func restore_original_auto_reload_setting():
	var settings := get_editor_interface().get_editor_settings()
	settings.set(AUTO_RELOAD_SETTING, original_auto_reload_setting)
