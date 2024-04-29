extends Resource
class_name WorkerRole

@export var id: String
@export var produce: Dictionary
@export var consume: Dictionary


func get_produce() -> Dictionary:
	return produce


func get_consume() -> Dictionary:
	return consume


func get_title() -> String:
	return id.capitalize()


func get_info() -> String:
	var info: String = "Produce: "
	info += ("+%s " + (", +%s ".join(produce.keys()))) % produce.values()
	if consume.size() > 0:
		info += (", -%s " + (", -%s ".join(consume.keys()))) % consume.values()
	info += " / %s seconds" % Game.params["cycle_seconds"]
	return info
