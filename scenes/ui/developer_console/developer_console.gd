extends Control
class_name DeveloperConsole

@export var history_limit: int = 16

@onready var command_log: RichTextLabel = %CommandLog
@onready var command_input: LineEdit = %CommandInput

signal command_history_changed()
signal command_entered(command: StringName, args: PackedStringArray)

var command_history_pointer: int = -1
var command_history: Array[String] = []

###############
## overrides ##
###############


func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	command_input.text_submitted.connect(_on_command_input_text_submitted)
	command_history_changed.connect(_on_command_history_changed)
	command_entered.connect(_on_command_entered)
	
	hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("developer_console_open"):
		_toggle_visibility()
	
	if event.is_action_pressed("developer_console_previous"):
		if command_history_pointer < 0:
			command_history_pointer = len(command_history) - 1
		else:
			command_history_pointer = max(0, command_history_pointer - 1)
		if  len(command_history) > 0:
			command_input.text = command_history[command_history_pointer]
	
	if event.is_action_pressed("developer_console_next"):
		command_history_pointer = min(len(command_history) - 1, command_history_pointer + 1)
		if command_history_pointer > 0:
			command_input.text = command_history[command_history_pointer]


###############
##  helpers  ##
###############

func _toggle_visibility() -> void:
	visible = !visible

func _write_line(message: String) -> void:
	command_history.push_back(message)
	if command_history.size() > history_limit:
		command_history.pop_front()
	command_history_changed.emit()

func _parse_command(command: StringName, args: PackedStringArray) -> void:
	match command.to_lower():
		&"add":
			var resource_id: String = args[0]
			if resource_id not in Resources.resource_generators.keys():
				_write_line("Unknown resource '%s'" % [resource_id])
				return
			if not args[1].is_valid_int():
				_write_line("Argument amount expected int, received '%s'" % [args[1]])
				return
				
			var amount: int = int(args[1])
			SignalBus.resource_generated.emit(resource_id, amount, "_DEVELOPER_CONSOLE")


###############
##  signals  ##
###############

func _on_visibility_changed() -> void:
	if visible:
		command_input.grab_focus()
	else:
		command_input.clear()

func _on_command_input_text_submitted(text: String) -> void:
	command_input.clear()
	_write_line(text)
	var tokens: PackedStringArray = text.split(" ")
	command_entered.emit(tokens[0], tokens.slice(1))

func _on_command_history_changed() -> void:
	command_log.text = '\n> '.join(command_history)

func _on_command_entered(command: StringName, args: PackedStringArray) -> void:
	_parse_command(command, args)
