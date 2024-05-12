extends Node

const AUTOSAVE_SECONDS: int = Game.params["autosave_seconds"]
const SAVE_SLOT: String = "_w3_d7_0"
const FILE_NAME: String = "save_data" + SAVE_SLOT + ".json"

@onready var timer: Timer = %AutosaveTimer

var resources: Dictionary = {}
var workers: Dictionary = {}
var events: Dictionary = {}
var event_log: Dictionary = {}
var resource_generator_unlocks: Array = ["land"]
var worker_role_unlocks: Array = []
var tab_unlocks: Array = ["world"]
var tab_levels: Dictionary = {"world": 0}
var settings: Dictionary = {"theme": "dark"}


func _ready() -> void:
	if !Game.params["save_system_enabled"]:
		return

	read()
	if Game.params["autosave_enabled"]:
		timer.wait_time = AUTOSAVE_SECONDS
		timer.timeout.connect(_on_timeout)
		timer.start()
	
	if Game.params["debug_logs"]:
		print("_READY: " + "SaveFile" + " | " + self.get_name())
		print("save_data: ")
		print(_get_save_data())


func autosave() -> void:
	write()


func write() -> void:
	var save_data: Dictionary = _get_save_data()
	var save_file: FileAccess = FileAccess.open("user://" + FILE_NAME, FileAccess.WRITE)
	var json_string: String = JSON.stringify(save_data)
	save_file.store_line(json_string)


func read() -> void:
	var file: FileAccess = FileAccess.open("user://" + FILE_NAME, FileAccess.READ)
	if file == null:
		return

	var content: String = file.get_as_text()
	var json_object: JSON = JSON.new()
	var _parse_err: Error = json_object.parse(content)
	if _parse_err != Error.OK:
		return

	var save_data: Dictionary = json_object.get_data()
	_set_save_data(save_data)


func _get_save_data() -> Dictionary:
	var save_data: Dictionary = {}
	save_data["resources"] = resources
	save_data["workers"] = workers
	save_data["events"] = events
	save_data["event_log"] = event_log
	save_data["resource_generator_unlocks"] = resource_generator_unlocks
	save_data["worker_role_unlocks"] = worker_role_unlocks
	save_data["tab_unlocks"] = tab_unlocks
	save_data["tab_levels"] = tab_levels
	save_data["settings"] = settings
	return save_data


func _set_save_data(save_data: Dictionary) -> Dictionary:
	resources = save_data.get("resources", resources)
	workers = save_data.get("workers", workers)
	events = save_data.get("events", events)
	event_log = save_data.get("event_log", event_log)
	resource_generator_unlocks = save_data.get(
		"resource_generator_unlocks", resource_generator_unlocks
	)
	worker_role_unlocks = save_data.get("worker_role_unlocks", worker_role_unlocks)
	tab_unlocks = save_data.get("tab_unlocks", tab_unlocks)
	tab_levels = save_data.get("tab_levels", tab_levels)
	settings = save_data.get("settings", settings)
	return save_data


func _on_timeout() -> void:
	autosave()
