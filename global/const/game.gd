class_name Game

const params: Dictionary = {"cycle_seconds": 2}

# TODO: ACTUAL STORY EVENTS
# TODO: USE GODOT RESOURCES INSTEAD OF LISTS IN DICTIONARY
const event_id_map: Dictionary = {
	"0": ["The world is dark and empty..."],
	"common": ["Found {amount} common resources. Never enough of these!"],
	"rare": ["Found {amount} rare resources."],
	"worker": ["Hired {amount} new workers."],
	"chapter":
	["Passive production of all resources is increasing! The age of automation is upon us. ***"]
}
