class_name NpcEvent
extends Resource

@export var sort_value: int = 0
@export var npc_id: String
@export var id: String
@export var next_npc_event_id: Array[String] = []


func get_sort_value() -> int:
	return sort_value


func get_npc_id() -> String:
	return npc_id


func get_id() -> String:
	return id


func get_options(n: int) -> String:
	return Locale.get_npc_event_options(id)[n]


func get_options_size() -> int:
	return Locale.get_npc_event_options(id).size()


func get_text() -> String:
	var text: String = Locale.get_npc_event_text(id)
	return text


func is_interactable() -> bool:
	var text: String = Locale.get_npc_event_text(id)
	return StringUtils.is_not_empty(text)
