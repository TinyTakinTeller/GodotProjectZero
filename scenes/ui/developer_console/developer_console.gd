class_name DeveloperConsole extends Control

@export var history_limit: int = 16

var command_history_pointer: int = -1
var command_history: Array[String] = []
var commands: Dictionary = {
	&"add": {"func": _cmd_add_resource, "usage": "add [resource_id] [amount]"},
	&"cls": {"func": _cmd_cls, "usage": "cls"}
}

@onready var command_log: RichTextLabel = %CommandLog
@onready var command_input: LineEdit = %CommandInput

###############
## overrides ##
###############


func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	command_input.text_submitted.connect(_on_command_input_text_submitted)
	hide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("developer_console_toggle"):
		_handle_input_toggle()

	if event.is_action_pressed("developer_console_previous_command"):
		_handle_input_previous_command()

	if event.is_action_pressed("developer_console_next_command"):
		_handle_input_next_command()

	if event.is_action_pressed("developer_console_clear_command"):
		command_input.clear()
		accept_event()


###############
##  helpers  ##
###############


func _add_command_to_history(command_text: String) -> void:
	if command_history.size() > 0 and command_history[-1] == command_text:
		# Don't add consecutive command to history
		return

	command_history.push_back(command_text)
	if command_history.size() > history_limit:
		command_history.pop_front()
	command_history_pointer = -1


func _handle_input_previous_command() -> void:
	if command_history.size() <= 0:
		return

	if command_history_pointer < 0:
		command_history_pointer = command_history.size() - 1
	else:
		command_history_pointer = max(0, command_history_pointer - 1)

	command_input.text = command_history[command_history_pointer]


func _handle_input_next_command() -> void:
	if command_history.size() <= 0 or command_history_pointer < 0:
		return

	if command_history_pointer == command_history.size() - 1:
		command_input.clear()
	else:
		command_history_pointer = min(command_history.size() - 1, command_history_pointer + 1)
		command_input.text = command_history[command_history_pointer]


func _handle_input_toggle() -> void:
	visible = !visible


func _write_line(message: String) -> void:
	command_log.text += "\n%s" % [message]


func _write_error(error_message: String) -> void:
	_write_line("Error: %s" % [error_message])


func _process_command(command_text: String) -> void:
	var tokens: PackedStringArray = command_text.split(" ")
	var command_name: StringName = tokens[0].to_lower()
	var command_args: PackedStringArray = tokens.slice(1)

	if commands.has(command_name):
		var command: Dictionary = commands[command_name]
		if command["func"].call(command_args) == OK:
			pass
		else:
			_write_line("Usage: %s" % [command["usage"]])

	else:
		_write_error("Command '%s' not found." % [command_name])


###############
## commands  ##
###############


func _cmd_add_resource(args: PackedStringArray) -> Error:
	var resource_id: String = args[0]
	if resource_id not in Resources.resource_generators.keys():
		return FAILED
	if not args[1].is_valid_int():
		return FAILED
	var amount: int = int(args[1])
	SignalBus.resource_generated.emit(resource_id, amount, name)
	return OK


func _cmd_cls(args: PackedStringArray) -> Error:
	if args.size() > 0:
		return FAILED
	command_log.text = ""
	return OK


###############
##  signals  ##
###############


func _on_visibility_changed() -> void:
	if visible:
		command_input.grab_focus()
	else:
		command_input.clear()


func _on_command_input_text_submitted(text: String) -> void:
	if text != "":
		command_input.clear()
		_write_line("> %s" % [text])
		_add_command_to_history(text)
		_process_command(text)
