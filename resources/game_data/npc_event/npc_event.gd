extends Resource
class_name NpcEvent

@export var sort_value: int = 0
@export var npc_id: String
@export var id: String
@export var text: String
@export var options: Array[String] = []
@export var next_npc_event_id: Array[String] = []


func get_sort_value() -> int:
	return sort_value


func get_npc_id() -> String:
	return npc_id


func get_id() -> String:
	return id


func get_text() -> String:
	return text


func is_interactable() -> bool:
	return text.length() != 0
