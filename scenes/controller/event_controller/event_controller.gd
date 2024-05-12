extends Node
class_name EventController


func _ready() -> void:
	owner.ready.connect(_on_owner_ready)
	SignalBus.progress_button_paid.connect(_on_progress_button_paid)
	#SignalBus.worker_efficiency_updated.connect(_on_worker_efficiency_updated)


func _trigger_zero_event() -> void:
	var event_id: String = "zero"
	if !_is_first_time(event_id):
		return
	_trigger_event(event_id, [])


func _retrigger_resource_generated_event(resource_generator: ResourceGenerator) -> void:
	var event_id: String = "resource_generated"
	var id: String = resource_generator.id
	var amount: int = resource_generator.get_amount()
	_trigger_event(event_id, [str(amount), id])


#func _check_automation_event(efficiencies: Dictionary) -> void:
#var event_id: String = "automation"
#if !_is_first_time(event_id):
#return
#
#var is_ready: bool = (
#efficiencies.size() >= 3 and efficiencies.values().all(func(e: int) -> bool: return e > 0)
#)
#if !is_ready:
#return
#
#_trigger_event(event_id, [])


func _is_first_time(event_id: String) -> bool:
	return SaveFile.events.get(event_id, 0) == 0


func _trigger_event(event_id: String, vals: Array) -> void:
	var event_data: EventData = Resources.event_datas[event_id]
	SignalBus.event_triggered.emit(event_data, vals)


func _on_owner_ready() -> void:
	_trigger_zero_event()


func _on_progress_button_paid(resource_generator: ResourceGenerator) -> void:
	if Game.params["debug_resource_generated_event"]:
		_retrigger_resource_generated_event(resource_generator)

#func _on_worker_efficiency_updated(efficiencies: Dictionary) -> void:
#_check_automation_event(efficiencies)
