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
	return (
		'''
async function customPrompt() {
	return new Promise((resolve) => {

// Define a global variable to store the textarea value
var globalTextAreaResult;

// Create a semi-transparent background overlay
var overlay = document.createElement("div");
overlay.style.position = "fixed";
overlay.style.top = "0";
overlay.style.left = "0";
overlay.style.width = "100%";
overlay.style.height = "100%";
overlay.style.backgroundColor = "rgba(0,0,0,0.5)";
overlay.style.zIndex = "9999"; // Ensure it's on top of other content

// Create the modal container
var modal = document.createElement("div");
modal.style.position = "fixed";
modal.style.top = "50%";
modal.style.left = "50%";
modal.style.transform = "translate(-50%, -50%)";
modal.style.backgroundColor = "#333"; // Set modal background to gray
modal.style.color = "white"; // Set text color to white for contrast
modal.style.padding = "20px";
modal.style.borderRadius = "8px";
modal.style.boxShadow = "0 2px 10px rgba(0, 0, 0, 0.1)";
modal.style.zIndex = "10000"; // Above the overlay
modal.style.minWidth = "500px"; // Set minimum width for the modal
modal.style.maxWidth = "80%"; // Limit modal width to a percentage of the viewport
modal.style.maxHeight = "80%"; // Limit modal height to a percentage of the viewport
modal.style.overflowY = "auto"; // Scroll if content is too long

// Create the title element
var modalTitle = document.createElement("h2");
modalTitle.textContent = "{atitle}";
modalTitle.style.marginTop = "0"; // Remove top margin
modalTitle.style.marginBottom = "5px"; // Add space below the title
modalTitle.style.color = "white"; // White text color for the title

// Create the subtitle element
var modalSubtitle = document.createElement("h3");
modalSubtitle.textContent = "{subtitle}";
modalSubtitle.style.marginTop = "0"; // Remove top margin
modalSubtitle.style.marginBottom = "15px"; // Add space below the subtitle
modalSubtitle.style.color = "lightgray"; // Light gray text color for the subtitle

// Create the textarea element
var textArea = document.createElement("textarea");
textArea.value = "{input}"
textArea.style.width = "100%"; // Make textarea full width
textArea.style.height = "275px"; // Set a fixed height for the textarea
textArea.style.backgroundColor = "#444"; // Darker gray background for textarea
textArea.style.color = "white"; // White text color
textArea.style.border = "2px solid #666"; // Add a default border color
textArea.style.borderRadius = "4px"; // Rounded corners
textArea.style.resize = "none"; // Prevent resizing
textArea.style.boxShadow = "0 0 5px rgba(255, 255, 255, 0.3)"; // Subtle shadow for unfocused state

// Add hover effect for the textarea
textArea.addEventListener('mouseover', function() {
	textArea.style.borderColor = "#888"; // Change border color on hover
});

textArea.addEventListener('mouseout', function() {
	textArea.style.borderColor = "#666"; // Revert border color when not hovering
});

// Append the title, subtitle, and textarea to the modal
modal.appendChild(modalTitle);
modal.appendChild(modalSubtitle);
modal.appendChild(textArea);

// Create a close button
var closeButton = document.createElement("button");
closeButton.textContent = "{button}";
closeButton.style.marginTop = "20px";
closeButton.style.display = "block";
closeButton.style.marginLeft = "auto";
closeButton.style.marginRight = "auto";
closeButton.style.backgroundColor = "#555"; // Darker gray background for button
closeButton.style.color = "white"; // White text color for button
closeButton.style.border = "none";
closeButton.style.padding = "10px 20px";
closeButton.style.borderRadius = "5px";
closeButton.onclick = function() {
	// Set the global variable to the value of the textarea
	globalTextAreaResult = textArea.value;
	window.globalTextAreaResult = textArea.value;
	resolve(textArea.value); // Resolve the promise with the textarea value
	// Remove modal and overlay from the document
	document.body.removeChild(modal);
	document.body.removeChild(overlay);
};

// Append the close button to the modal
modal.appendChild(closeButton);

// Append the modal and overlay to the body
document.body.appendChild(overlay);
document.body.appendChild(modal);

	});
}
customPrompt();
'''
		. format({"input": input, "atitle": atitle, "subtitle": subtitle, "button": button})
	)
