extends Node
class_name EventManager


func _ready() -> void:
	SignalBus.event_triggered.connect(_on_event_triggered)
	owner.ready.connect(_on_owner_ready)


func _add_event(id: String, args: Dictionary) -> void:
	if !Game.event_id_map.has(id):
		return
	var index: int = SaveFile.events.size() + 1
	SaveFile.events[index] = {"id": id, "args": args}
	var content: String = _get_event_content(index)
	SignalBus.event_saved.emit(content, index)


func _get_event_content(index: int) -> String:
	var id: String = SaveFile.events[index]["id"]
	var args: Dictionary = SaveFile.events[index]["args"]
	var content: String = "\n".join(Game.event_id_map[id]).format(args)
	return content


func _on_event_triggered(id: String, args: Dictionary) -> void:
	_add_event(id, args)


func _on_owner_ready() -> void:
	_add_event("0", {})
