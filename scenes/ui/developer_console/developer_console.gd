class_name DeveloperConsole extends Control

@export var buffer_size: int = 16

var commands: Dictionary = {
	&"add": {"func": _cmd_add_resource, "usage": "add [resource_id] [amount]"},
	&"cls": {"func": _cmd_cls, "usage": "cls"}
}

var input_buffer: Array[String] = []
var input_pointer: int = -1

var output_buffer: Array[String] = []

@onready var command_output: RichTextLabel = %CommandOutput
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


func _input_buffer_add_command(command_text: String) -> void:
	if input_buffer.size() > 0 and input_buffer[-1] == command_text:
		# Don't add consecutive command to input buffer
		return

	input_buffer.push_back(command_text)
	if input_buffer.size() > buffer_size:
		input_buffer.pop_front()
	input_pointer = -1


func _handle_input_previous_command() -> void:
	if input_buffer.size() <= 0:
		return

	if input_pointer < 0:
		input_pointer = input_buffer.size() - 1
	else:
		input_pointer = max(0, input_pointer - 1)

	command_input.text = input_buffer[input_pointer]


func _handle_input_next_command() -> void:
	if input_buffer.size() <= 0 or input_pointer < 0:
		return

	if input_pointer == input_buffer.size() - 1:
		command_input.clear()
	else:
		input_pointer = min(input_buffer.size() - 1, input_pointer + 1)
		command_input.text = input_buffer[input_pointer]


func _handle_input_toggle() -> void:
	visible = !visible


func _write_line(message: String) -> void:
	output_buffer.push_back(message)
	if output_buffer.size() > buffer_size:
		output_buffer.pop_front()
	_flush_output()


func _write_error(error_message: String) -> void:
	_write_line("Error: %s" % [error_message])


func _flush_output() -> void:
	command_output.text = "\n".join(output_buffer)


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
	output_buffer.clear()
	_flush_output()
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
		_input_buffer_add_command(text)
		_process_command(text)
