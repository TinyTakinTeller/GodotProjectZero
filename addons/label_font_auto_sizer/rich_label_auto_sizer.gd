@tool
@icon ("res://addons/label_font_auto_sizer/icon.svg")
extends RichTextLabel
class_name RichLabelAutoSizer

#region External variables
## The maximum size value in pixels that the font will grow to.
@export_range(1, 192, 1, "or_greater", "suffix:px") var _max_size: int = 64:
	set(value):
		if value >_min_size:
			_max_size = value
		else:
			_max_size = _min_size
		if is_node_ready(): ## This setter gets called when the label enters the tree in the editor, even before it's ready. This if check prevents it.
			call_deferred(_check_line_count.get_method())
## The minimum size value in pixels that the font will shrink to.
@export_range(1, 192, 1, "or_greater", "suffix:px") var _min_size: int = 1:
	set(value):
		if value < _max_size:
			_min_size = value
		else:
			_min_size = _max_size
		if is_node_ready(): ## Same as _max_size comment.
			call_deferred(_check_line_count.get_method())
@export var _lock_size_in_editor: bool =  false:
	set(value):
		_lock_size_in_editor = value
		if value == false:
			call_deferred(_check_line_count.get_method())
#endregion

#region Internal variables
@export_storage var _current_font_size: int
@export_storage var _last_size_state: LABEL_SIZE_STATE = LABEL_SIZE_STATE.IDLE
@export_storage var _size_just_modified_by_autosizer: bool = false
@export_storage var _editor_defaults_set: bool = false
var _label_settings_just_duplicated: bool = false
enum LABEL_SIZE_STATE {JUST_SHRUNK, IDLE, JUST_ENLARGED} 
#endregion


#region Virtual/Signal functions
## Gets called in-editor and in-game. Sets some default values if necessary.
func _ready() -> void:
	if !_editor_defaults_set:
		call_deferred(_set_editor_defaults.get_method())
	if Engine.is_editor_hint():
		call_deferred(_connect_signals.get_method())
	else:
		call_deferred(_check_line_count.get_method())
	LabelFontAutoSizeManager.register_label(self)


## Gets called when there are changes in either the Theme or Label Settings resources.
## Checks if the change was made by the script of by the user and if not, sets the base font size value.
func _on_font_resource_changed() -> void:
	if _size_just_modified_by_autosizer:
		_size_just_modified_by_autosizer = false ## Early return because the change wasn't made by the user.
	else:
		_apply_font_size(_current_font_size)


## Gets called whenever the size of the control rect is modified (in editor). Calls the line count check.
func _on_label_rect_resized() -> void:
	if !_editor_defaults_set:
		return
	call_deferred(_check_line_count.get_method())


## Called by autosize manager whenever the locale_chaged() method is called, as the tr() object changes don't trigger
## the set_text() method of the label, thus the size and line_amount doesn't get checked.
func _on_locale_changed() -> void:
	call_deferred(_check_line_count.get_method())


## Gets called on scene changes and when the label is freed and erases itself from the autosize manager.
func _exit_tree() -> void:
	LabelFontAutoSizeManager.erase_label(self)
#endregion


#region Private functions
##Only in-editor, keeps stuff in check while manually changing font resources and resizing the label.
func _connect_signals() -> void:
	if !theme_changed.is_connected(_on_font_resource_changed):
		theme_changed.connect(_on_font_resource_changed)
	if !resized.is_connected(_on_label_rect_resized):
		resized.connect(_on_label_rect_resized)


## Text can be changed via either: set_text(value), or _my_label.text = value. Both will trigger a line check.
##**If you're doing some testing/developing, if you are changing the text from withit one of the label classes themselves, do it like self.set_text(value) or self.text = value, othersise it doesn't trigger a size check.
##In a real scenario you wouldn't be changing the text from within the class itself though.**
func _set(property: StringName, value: Variant) -> bool:
	match property:
		"text":
			text = value
			call_deferred(_check_line_count.get_method())
			return true
		_:
			return false


## Goes through the resources in the label and sets the base font size value.
## Priority: Override Theme Font Size > Theme Font Size. (RichTextLabels don't allow Label Settings)
func _check_font_size() -> void:
	if get("theme_override_font_sizes/normal_font_size") != null:
		_current_font_size = get("theme_override_font_sizes/normal_font_size")
	elif get_theme_font_size("normal_font_size") != null:
		_current_font_size = get_theme_font_size("normal_font_size")


## Checks the current font size and amount of lines in the text against the visible lines inside the rect.
## Calls for the shrink or enlarge methods accordingly.
func _check_line_count() -> void:
	if Engine.is_editor_hint() and _lock_size_in_editor:
		return
	
	if _current_font_size > _max_size and _current_font_size > _min_size:
		_shrink_font()
		return
	elif get_content_height() > size.y or get_content_width() > size.x:
		if _current_font_size > _min_size:
			_shrink_font()
			return
	
	if _current_font_size < _max_size and _current_font_size < _min_size:
		_enlarge_font()
		return
	elif get_content_height() <= size.y or get_content_width() <= size.x:
		if _current_font_size < _max_size:
			_enlarge_font()
			return
	_last_size_state = LABEL_SIZE_STATE.IDLE


## Makes the font size smaller. Rechecks or stops the cycle depending on the conditions.
func _shrink_font():
	_apply_font_size(_current_font_size - 1)
	if _last_size_state == LABEL_SIZE_STATE.JUST_ENLARGED: ## To stop infinite cycles.
		_last_size_state = LABEL_SIZE_STATE.IDLE
	else:
		_last_size_state = LABEL_SIZE_STATE.JUST_SHRUNK
		call_deferred(_check_line_count.get_method())


## Makes the font size larger. Rechecks/Shrinks/stops the cycle depending on the conditions.
func _enlarge_font():
	_apply_font_size(_current_font_size + 1)
	if _last_size_state == LABEL_SIZE_STATE.JUST_SHRUNK:
		if  get_content_height() > size.y:
			_last_size_state = LABEL_SIZE_STATE.JUST_ENLARGED
			_shrink_font()
		else: ## To stop infinite cycles.
			_last_size_state = LABEL_SIZE_STATE.IDLE
	else:
		_last_size_state = LABEL_SIZE_STATE.JUST_ENLARGED
		call_deferred(_check_line_count.get_method())


## Applies the new font size.
func _apply_font_size(new_size: int) -> void:
	_size_just_modified_by_autosizer = true
	set("theme_override_font_sizes/normal_font_size", new_size)
	_current_font_size = new_size
#endregion


#region Public functions
## Gets called in-editor and sets the default values.
func _set_editor_defaults() -> void:
	_editor_defaults_set =  true
	clip_contents = true
	fit_content = false
	scroll_active = false
	autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_check_font_size()
	_connect_signals()
	set_deferred("_max_size", _current_font_size)


## Text can be changed via either: set_text(value), or _my_label.text = value. Both will trigger a line check.
##**If you're doing some testing/developing, if you are changing the text from withit one of the label classes themselves, do it like self.set_text(value) or self.text = value, othersise it doesn't trigger a size check.
##In a real scenario you wouldn't be changing the text from within the class itself though.**
func set_text(new_text: String) -> void:
	text = new_text
	call_deferred(_check_line_count.get_method())
#endregion

