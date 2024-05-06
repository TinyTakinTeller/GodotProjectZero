extends Node
class_name EventManager


func _ready() -> void:
	SignalBus.event_triggered.connect(_on_event_triggered)


func _add_event(event_data: EventData, vals: Array) -> void:
	var event_data_id: String = event_data.id
	SaveFile.events[event_data_id] = SaveFile.events.get(event_data_id, 0) + 1
	var index: int = SaveFile.event_log.size() + 1
	SaveFile.event_log[str(index)] = {"event_data": event_data_id, "vals": vals}
	SignalBus.event_saved.emit(event_data, vals, index)


func _on_event_triggered(event_data: EventData, vals: Array) -> void:
	_add_event(event_data, vals)
