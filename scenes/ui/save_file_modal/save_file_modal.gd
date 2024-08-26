class_name SaveFileModal extends Control

enum Mode { IMPORT, EXPORT }

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


func _on_open_export_modal(save_file_name: String) -> void:
	open(Mode.EXPORT, save_file_name)


func _on_close_button() -> void:
	close()


func _on_accept_button() -> void:
	close()


func _on_import_button() -> void:
	_handle_save_file_import()
