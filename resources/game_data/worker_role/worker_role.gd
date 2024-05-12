extends Resource
class_name WorkerRole

@export var sort_value: int = 0
@export var id: String
@export var title: String
@export var flavor: String
@export var produce: Dictionary
@export var consume: Dictionary
@export var default: bool = false
@export var column: int = 0


func get_produce() -> Dictionary:
	return produce


func get_consume() -> Dictionary:
	return consume


func get_title() -> String:
	if title != null and title.length() > 1:
		return title
	return WorkerRole._humanify_string(id)


func get_info() -> String:
	var info: String = "Produce: "
	info += ("+%s " + (", +%s ".join(produce.keys()))) % produce.values()
	if consume.size() > 0:
		info += (", -%s " + (", -%s ".join(consume.keys()))) % consume.values()
	info += " / %s seconds" % Game.params["cycle_seconds"]
	if flavor.length() > 1:
		info += " - " + flavor
	return info


static func _humanify_string(s: String) -> String:
	return s.capitalize().replace("_", " ")
