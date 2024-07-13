class_name EventData
extends Resource

@export var id: String
@export var vars: Array = []
@export var color: Color = Color.BLACK


func get_text(vals: Array) -> String:
	var args: Dictionary = EventData.get_args(vals)
	var text: String = Locale.get_event_data_text(id)
	return text.format(args)


static func get_args(vals: Array) -> Dictionary:
	var args: Dictionary = {}
	for i in range(vals.size()):
		var key: int = i
		var val: String = vals[i]
		args[key] = val
	return args
