class_name StateMachine extends Node

@export var default_state: StateMachineState

var states: Dictionary
var current_state: StateMachineState


func _ready() -> void:
	for child in get_children():
		states[child.name] = child
		child._on_ready()

	await owner.ready
	transition_to(default_state.name)


func _input(event: InputEvent) -> void:
	current_state._on_input(event)


func _process(delta: float) -> void:
	current_state._on_process(delta)


func _physics_process(delta: float) -> void:
	current_state._on_physics_process(delta)


func transition_to(state_name: StringName) -> void:
	if current_state:
		current_state._on_state_exit()
	current_state = states[state_name]
	current_state._on_state_enter()
