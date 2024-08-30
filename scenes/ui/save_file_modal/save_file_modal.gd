class_name SaveFileModal extends Control

enum Mode { IMPORT, EXPORT }

var text_modal_js_path: String = "res://native/js/text_modal.js"
var text_modal_js: String = FileSystemUtils.read_text_from(text_modal_js_path)

@onready var title: Label = %Title
@onready var text_area: TextEdit = %TextArea
@onready var close_button: Button = %CloseButton
@onready var import_button: Button = %ImportButton
@onready var accept_button: Button = %AcceptButton
@onready var tooltip: Label = %Tooltip
@onready var error_message: Label = %ErrorMessage

###############
## overrides ##
###############


func _ready() -> void:
	_initialize()
	_connect_signals()


#############
## helpers ##
#############


func _initialize() -> void:
	visible = false
	text_area.clear()

	if Game.PARAMS["debug_logs"]:
		prints("NATIVE JS files", FileSystemUtils.get_files_at("res://native/js/"))


func _set_import_ui_labels() -> void:
	title.text = Locale.get_ui_label("import_title")
	import_button.text = Locale.get_ui_label("import")
	accept_button.text = ""
	text_area.placeholder_text = Locale.get_ui_label("import_placeholder")
	error_message.text = ""
	tooltip.text = Locale.get_ui_label("import_tooltip")


func _set_export_ui_labels() -> void:
	title.text = Locale.get_ui_label("export_title")
	import_button.text = ""
	accept_button.text = Locale.get_ui_label("accept")
	text_area.placeholder_text = ""
	error_message.text = ""
	tooltip.text = Locale.get_ui_label("export_tooltip")


func _set_modal_options(mode: Mode, save_file_name: String) -> void:
	error_message.hide()

	match mode:
		Mode.IMPORT:
			_set_import_ui_labels()
			text_area.editable = true
			accept_button.hide()
			import_button.show()
		Mode.EXPORT:
			_set_export_ui_labels()
			text_area.editable = false
			accept_button.show()
			import_button.hide()

			_load_save_file_string(save_file_name)
		_:
			push_error("Unknown mode %s" % mode)


func _load_save_file_string(save_file_name: String) -> void:
	text_area.text = SaveFile.export_as_string(save_file_name)


func _handle_save_file_import() -> void:
	var import_success: bool = SaveFile.import_from_string(text_area.text)
	if import_success:
		close()
	else:
		error_message.text = Locale.get_ui_label("import_error")
		error_message.show()
		visible = true


#############
## methods ##
#############


func open(mode: Mode, save_file_name: String = "") -> void:
	_set_modal_options(mode, save_file_name)
	visible = true


func close() -> void:
	text_area.clear()
	visible = false


#############
## signals ##
#############


func _connect_signals() -> void:
	close_button.button_up.connect(_on_close_button)
	accept_button.button_up.connect(_on_accept_button)
	import_button.button_up.connect(_on_import_button)
	SignalBus.open_import_modal.connect(_on_open_import_modal)
	SignalBus.open_export_modal.connect(_on_open_export_modal)


func _on_open_import_modal() -> void:
	open(Mode.IMPORT)

	if Game.PARAMS["CLIPBOARD_WEB_WORKAROUND"]:
		visible = false
		import_button.visible = false
		text_area.editable = false
		prints("JavaScriptBridge...")
		## uh oh...
		#var command: String = 'prompt("Import Save File Code");'
		#print(command)
		## CUSTOM NATIVE WORKAROUND:
		var eval_return: String = await _await_native_js_popup_command(
			Locale.get_ui_label("import_placeholder"),
			Locale.get_ui_label("import_title"),
			Locale.get_ui_label("import_tooltip"),
			Locale.get_ui_label("accept")
		)
		if eval_return != null:
			prints("JavaScriptBridge Import", eval_return)
			text_area.text = eval_return as String
		_on_import_button()


func _on_open_export_modal(save_file_name: String) -> void:
	open(Mode.EXPORT, save_file_name)

	if Game.PARAMS["CLIPBOARD_WEB_WORKAROUND"]:
		visible = false
		prints("JavaScriptBridge...")
		## truncated by ellipsis "..." if too long :/
		#var command: String = 'prompt("Export Save File Code", "{0}");'.format(
		#	{"0": text_area.text}
		#)
		## truncated by ellipsis "..." if too long :/
		# var command: String = 'alert("{0}");'.format({"0": text_area.text})
		## CUSTOM NATIVE WORKAROUND:
		var eval_return: Variant = await _await_native_js_popup_command(
			text_area.text,
			Locale.get_ui_label("export_title"),
			Locale.get_ui_label("export_tooltip"),
			Locale.get_ui_label("accept")
		)
		if eval_return != null:
			prints("JavaScriptBridge Export", eval_return as String)
			text_area.text = eval_return
		_on_accept_button()


func _on_close_button() -> void:
	close()


func _on_accept_button() -> void:
	close()


func _on_import_button() -> void:
	_handle_save_file_import()


###########
## hacks ##
###########


func _await_native_js_popup_command(
	input: String, atitle: String, subtitle: String, button: String
) -> String:
	var command: String = _get_native_js_popup_command(input, atitle, subtitle, button)
	var eval_return: Variant = JavaScriptBridge.eval(command)
	while true:
		eval_return = JavaScriptBridge.eval("window.globalTextAreaResult")
		if eval_return != null:
			break
		await get_tree().create_timer(0.1).timeout
	JavaScriptBridge.eval("window.globalTextAreaResult = null;")
	return eval_return


func _get_native_js_popup_command(
	input: String, atitle: String, subtitle: String, button: String
) -> String:
	return text_modal_js.format(
		{"input": input, "atitle": atitle, "subtitle": subtitle, "button": button}
	)
