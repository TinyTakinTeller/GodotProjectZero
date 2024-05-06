extends Resource
class_name EventData

@export var id: String
@export var text: String
@export var vars: Array = []
@export var color: Color = Color.BLACK


func get_text(vals: Array) -> String:
	var args: Dictionary = EventData.get_args(vals)
	return text.format(args)


static func get_args(vals: Array) -> Dictionary:
	var args: Dictionary = {}
	for i in range(vals.size()):
		var key: int = i
		var val: String = vals[i]
		args[key] = val
	return args
