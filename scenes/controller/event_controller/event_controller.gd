class_name EventController
extends Node

###############
## overrides ##
###############


func _ready() -> void:
	_connect_signals()


#############
## helpers ##
#############


func _is_first_time(event_id: String) -> bool:
	return SaveFile.events.get(event_id, 0) == 0


func _trigger_event(event_id: String, vals: Array) -> void:
	var event_data: EventData = Resources.event_datas[event_id]
	SignalBus.event_triggered.emit(event_data, vals)


func _trigger_unique_event(event_id: String) -> void:
	if !_is_first_time(event_id):
		return
	_trigger_event(event_id, [])


func _retrigger_resource_generated_event(resource_generator: ResourceGenerator) -> void:
	var event_id: String = "resource_generated"
	var id: String = resource_generator.id
	var amount: int = resource_generator.get_amount()
	_trigger_event(event_id, [str(amount), id])


##############
## handlers ##
##############


func _handle_on_progress_button_paid(resource_generator: ResourceGenerator) -> void:
	if Game.PARAMS["debug_resource_generated_event"]:
		_retrigger_resource_generated_event(resource_generator)


func _handle_on_owner_ready() -> void:
	_trigger_unique_event("zero")


#############
## signals ##
#############


func _connect_signals() -> void:
	owner.ready.connect(_on_owner_ready)
	SignalBus.progress_button_paid.connect(_on_progress_button_paid)


func _on_owner_ready() -> void:
	_handle_on_owner_ready()

func _on_progress_button_paid(resource_generator: ResourceGenerator, _source: String) -> void:
	_handle_on_progress_button_paid(resource_generator)
