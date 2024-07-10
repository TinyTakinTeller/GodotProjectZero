extends Node

const SIGNATURE = "$$$"
const SAVE_FILE_EXTENSION = ".json"
const AUTOSAVE_SECONDS: int = Game.params["autosave_seconds"]

var active_file_name: String = "default"
var save_datas: Dictionary = {}

var resources: Dictionary = {}
var workers: Dictionary = {}
var events: Dictionary = {}
var event_log: Dictionary = {}
var resource_generator_unlocks: Array = ["land"]
var worker_role_unlocks: Array = []
var tab_unlocks: Array = ["world", "settings"]
var tab_levels: Dictionary = {"world": 0}
var settings: Dictionary = {"theme": "dark"}
var audio_settings: Dictionary = {
	"master": {"value": 1.00, "toggle": true},
	"music": {"value": 0.80, "toggle": true},
	"sfx": {"value": 0.50, "toggle": true}
}
var npc_events: Dictionary = {}
var enemy: Dictionary = {"level": "rabbit", "rabbit": {"damage": 0}}
var metadata: Dictionary = {}
var locale: String = "en"

@onready var autosave_timer: Timer = %AutosaveTimer

###############
## overrides ##
###############


func _ready() -> void:
	_load_save_files()
	_connect_signals()

	if Game.params["debug_logs"]:
		print("_AUTOLOAD _READY: " + self.get_name())


#############
## getters ##
#############


func get_enemy_option(id: String) -> int:
	var first: int = enemy[id].get("option", {}).get("1", 0)
	var second: int = enemy[id].get("option", {}).get("2", 0)
	if first == 0 and second == 0:
		return 0
	return 1 if first > second else 2


func get_enemy_ids() -> Array:
	return enemy.keys().filter(
		func(id: String) -> bool: return id != "level" and get_enemy_option(id) > 0
	)


func get_enemy_ids_for_option(option: int) -> Array:
	return enemy.keys().filter(
		func(id: String) -> bool: return id != "level" and get_enemy_option(id) == option
	)


func get_enemy_damage(enemy_id: String = "") -> int:
	if enemy_id == "":
		enemy_id = SaveFile.enemy.get("level", "NULL")

	var enemy_progression: Dictionary = SaveFile.enemy.get(enemy_id, {})
	var enemy_damage: int = enemy_progression.get("damage", 0)
	return enemy_damage


func get_settings_theme(save_file_name: String) -> Resource:
	var theme_id: String = Game.params["default_theme"]
	if !save_datas.has(save_file_name):
		return Resources.theme.get(theme_id, null)

	var save_data: Dictionary = save_datas[save_file_name]
	var saved_settings: Dictionary = save_data.get("settings", {})
	theme_id = saved_settings.get("theme", "")
	return Resources.theme.get(theme_id, null)


func get_settings_population_scale() -> int:
	return settings.get("population_scale", 1)


#############
## setters ##
#############


func set_enemy(enemy_id: String, option: int) -> void:
	var active_enemy_id: String = SaveFile.enemy["level"]

	SaveFile.enemy[active_enemy_id] = SaveFile.enemy.get(active_enemy_id, {})
	var enemy_progression: Dictionary = SaveFile.enemy[active_enemy_id]

	enemy_progression["option"] = enemy_progression.get("option", {})
	var options: Dictionary = enemy_progression["option"]

	options[str(option)] = options.get(str(option), 0) + 1

	SaveFile.enemy["level"] = enemy_id
	set_enemy_damage(0)


func set_enemy_damage(damage: int) -> int:
	var active_enemy_id: String = SaveFile.enemy["level"]

	SaveFile.enemy[active_enemy_id] = SaveFile.enemy.get(active_enemy_id, {})
	var enemy_progression: Dictionary = SaveFile.enemy[active_enemy_id]

	enemy_progression["damage"] = damage
	return enemy_progression["damage"]


func add_enemy_damage(damage: int) -> int:
	var active_enemy_id: String = SaveFile.enemy["level"]
	var enemy_progression: Dictionary = SaveFile.enemy.get(active_enemy_id, {})
	enemy_progression["damage"] = enemy_progression.get("damage", 0) + damage
	return enemy_progression["damage"]


func set_metadata_name(save_file_name: String, value: String) -> void:
	if !save_datas.has(save_file_name):
		return

	var save_data: Dictionary = save_datas[save_file_name]
	var saved_metadata: Dictionary = save_data.get("metadata", {})
	saved_metadata["save_file_name"] = value


###########
## setup ##
###########


func initialize(save_file_name: String, metadata_name: String) -> void:
	if !Game.params["save_system_enabled"]:
		return

	var file_name: String = save_file_name + SAVE_FILE_EXTENSION
	active_file_name = file_name

	if save_datas.has(save_file_name):
		var save_data: Dictionary = save_datas[save_file_name]
		if save_data != null and !save_data.is_empty():
			_import_save_data(save_data)
	elif StringUtils.is_not_empty(metadata_name):
		metadata["save_file_name"] = metadata_name

	_connect_autosave_timer()


func delete(save_file_name: String) -> void:
	var file_name: String = save_file_name + SAVE_FILE_EXTENSION
	var error: Error = DirAccess.remove_absolute(FileSystemUtils.USER_PATH + file_name)
	if Game.params["debug_logs"]:
		print("Delete save file '" + save_file_name + "' response: " + str(error))
	save_datas.erase(save_file_name)


func rename(save_file_name: String, new_text: String, old_text: String) -> void:
	set_metadata_name(save_file_name, new_text)

	var file_name: String = save_file_name + SAVE_FILE_EXTENSION
	var to_replace: String = _metadata_save_file_name_internal(old_text)
	var to_set: String = _metadata_save_file_name_internal(new_text)
	_replace(file_name, to_replace, to_set)


#############
## helpers ##
#############


func _save_entered() -> void:
	var seconds_delta: int = _get_seconds_since_last_autosave()

	SignalBus.save_entered.emit(seconds_delta, AUTOSAVE_SECONDS)

	_update_metadata()


func _autosave(force: bool = false, silent: bool = false) -> void:
	var seconds_delta: int = _get_seconds_since_last_autosave()
	if not force and seconds_delta < AUTOSAVE_SECONDS:
		return

	if not silent:
		SignalBus.autosave.emit(seconds_delta, AUTOSAVE_SECONDS)

	var file_name: String = active_file_name
	_update_metadata()
	_write(file_name)


func _get_seconds_since_last_autosave() -> int:
	var now_time: Dictionary = Time.get_datetime_dict_from_system(true)
	var last_time: Dictionary = metadata.get("last_utc_time", now_time)
	var unix_delta: int = (
		Time.get_unix_time_from_datetime_dict(now_time)
		- Time.get_unix_time_from_datetime_dict(last_time)
	)
	return unix_delta


func _load_save_files() -> void:
	if !Game.params["save_system_enabled"]:
		return

	for file_name: String in FileSystemUtils.get_user_files():
		if !file_name.ends_with(SAVE_FILE_EXTENSION):
			continue
		var save_data: Dictionary = _read(file_name)
		_check_backward_compatibility(save_data)
		if Game.params["debug_logs"]:
			print("__LOAD_SAVE_DATA: " + file_name)
			print(save_data)
		if save_data == null or save_data.is_empty():
			continue
		var save_file_name: String = file_name.trim_suffix(SAVE_FILE_EXTENSION)
		save_datas[save_file_name] = save_data


func _export_save_data() -> Dictionary:
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
	save_data["audio_settings"] = audio_settings
	save_data["npc_events"] = npc_events
	save_data["enemy"] = enemy
	save_data["metadata"] = metadata
	save_data["LOCALE"] = locale
	return save_data


func _import_save_data(save_data: Dictionary) -> void:
	resources = _get_resources(save_data)
	workers = _get_workers(save_data)
	events = _get_events(save_data)
	event_log = _get_event_log(save_data)
	resource_generator_unlocks = _get_resource_generator_unlocks(save_data)
	worker_role_unlocks = _get_worker_role_unlocks(save_data)
	tab_unlocks = _get_tab_unlocks(save_data)
	tab_levels = _get_tab_levels(save_data)
	settings = _get_settings(save_data)
	audio_settings = _get_audio_settings(save_data)
	npc_events = _get_npc_events(save_data)
	enemy = _get_enemy(save_data)
	metadata = _get_metadata(save_data)
	locale = _get_locale(save_data)


func _get_resources(save_data: Dictionary) -> Dictionary:
	return save_data.get("resources", resources)


func _get_workers(save_data: Dictionary) -> Dictionary:
	return save_data.get("workers", workers)


func _get_events(save_data: Dictionary) -> Dictionary:
	return save_data.get("events", events)


func _get_event_log(save_data: Dictionary) -> Dictionary:
	return save_data.get("event_log", event_log)


func _get_resource_generator_unlocks(save_data: Dictionary) -> Array:
	return save_data.get("resource_generator_unlocks", resource_generator_unlocks)


func _get_worker_role_unlocks(save_data: Dictionary) -> Array:
	return save_data.get("worker_role_unlocks", worker_role_unlocks)


func _get_tab_unlocks(save_data: Dictionary) -> Array:
	return save_data.get("tab_unlocks", tab_unlocks)


func _get_tab_levels(save_data: Dictionary) -> Dictionary:
	return save_data.get("tab_levels", tab_levels)


func _get_settings(save_data: Dictionary) -> Dictionary:
	return save_data.get("settings", settings)


func _get_audio_settings(save_data: Dictionary) -> Dictionary:
	return save_data.get("audio_settings", audio_settings)


func _get_npc_events(save_data: Dictionary) -> Dictionary:
	return save_data.get("npc_events", npc_events)


func _get_enemy(save_data: Dictionary) -> Dictionary:
	return save_data.get("enemy", enemy)


func _get_metadata(save_data: Dictionary) -> Dictionary:
	return save_data.get("metadata", metadata)


func _get_locale(save_data: Dictionary) -> String:
	return save_data.get("LOCALE", locale)


func _update_metadata() -> void:
	metadata["last_utc_time"] = Time.get_datetime_dict_from_system(true)
	metadata["last_timezone"] = Time.get_time_zone_from_system()
	_sanitize_timezone(metadata["last_timezone"])
	metadata["last_version_major"] = Game.VERSION_MAJOR
	metadata["last_version_minor"] = Game.VERSION_MINOR
	metadata["total_autosave_seconds"] = (
		metadata.get("total_autosave_seconds", 0) + AUTOSAVE_SECONDS
	)
	if metadata.get("first_utc_time", null) == null:
		metadata["first_utc_time"] = Time.get_datetime_dict_from_system(true)
	if metadata.get("first_timezone", null) == null:
		metadata["first_timezone"] = Time.get_time_zone_from_system()
		_sanitize_timezone(metadata["first_timezone"])
	if metadata.get("first_version_major", null) == null:
		metadata["first_version_major"] = Game.VERSION_MAJOR
	if metadata.get("first_version_minor", null) == null:
		metadata["first_version_minor"] = Game.VERSION_MINOR
	if metadata.get("save_file_name", null) == null:
		metadata["save_file_name"] = "unnamed"


func _sanitize_timezone(timezone: Dictionary) -> void:
	timezone["bias"] = int(timezone["bias"])
	timezone["name"] = StringUtils.sanitize_text(timezone.get("name", ""), StringUtils.ASCII)


func _check_backward_compatibility(save_data: Dictionary) -> void:
	_check_backward_week_5(save_data)
	_check_backward_week_7(save_data)
	_check_backward_week_10(save_data)
	_check_backward_corrupt_worker_role(save_data)


## [WORKAROUND] for #ADF-27 | https://trello.com/c/7VNXK6xW
func _check_backward_corrupt_worker_role(save_data: Dictionary) -> void:
	var max_worker_resource: int = (
		Limits.GLOBAL_MAX_AMOUNT + save_data["resources"].get("swordsman", 0)
	)
	if save_data["resources"].get(Game.WORKER_RESOURCE_ID, 0) > max_worker_resource:
		save_data["resources"][Game.WORKER_RESOURCE_ID] = max_worker_resource

	var max_worker_role: int = Limits.GLOBAL_MAX_AMOUNT
	if save_data["workers"].get(Game.WORKER_RESOURCE_ID, 0) > max_worker_role:
		save_data["workers"][Game.WORKER_RESOURCE_ID] = max_worker_role

	var total_roles: int = 0
	for id: String in save_data["workers"]:
		total_roles += save_data["workers"][id]
	var worker_resources: int = save_data["resources"].get(Game.WORKER_RESOURCE_ID, 0)
	var error: int = worker_resources - total_roles
	if error != 0:
		if Game.params["debug_logs"]:
			print(
				(
					"[WORKAROUND] workers error: "
					+ str(error)
					+ " : "
					+ str(total_roles)
					+ " / "
					+ str(worker_resources)
					+ " at "
					+ str(save_data["metadata"].get("save_file_name", "NULL"))
				)
			)
		if error > 0:
			save_data["workers"][Game.WORKER_RESOURCE_ID] = (
				save_data["workers"].get(Game.WORKER_RESOURCE_ID, 0) + error
			)
		elif error < 0:
			save_data["resources"][Game.WORKER_RESOURCE_ID] = (
				save_data["resources"].get(Game.WORKER_RESOURCE_ID, 0) - error
			)


## version week 10 (and before) did not have settings tab
func _check_backward_week_10(save_data: Dictionary) -> void:
	if !save_data["tab_unlocks"].has("settings"):
		save_data["tab_unlocks"].append("settings")


## version week 7 (and before) had a temporary enemy or no enemy
func _check_backward_week_7(save_data: Dictionary) -> void:
	var check_enemy: String = save_data.get("enemy", {}).get("level", "")
	if check_enemy == "" or check_enemy == "ambassador":
		save_data["enemy"] = {"level": "rabbit", "rabbit": {"damage": 0}}


## cat dialogue tree was extended in week 6, this resets the last answer so dialogue can continue
func _check_backward_week_5(save_data: Dictionary) -> void:
	var target_version: Array[String] = ["week 3", "week 4", "week 5"]
	var last_version: String = _get_metadata(save_data).get("last_version_minor", "")
	if !target_version.has(last_version):
		return

	var cat_events: Dictionary = _get_npc_events(save_data).get("cat", {})
	if cat_events.get("cat_intro", 0) != 0:
		cat_events["cat_intro"] = -1

	_get_metadata(save_data)["last_version_minor"] = Game.VERSION_MINOR


##############
## signals ##
##############


func _connect_signals() -> void:
	SignalBus.main_ready.connect(_on_main_ready)
	SignalBus.offline_progress_processed.connect(_on_offline_progress_processed)


func _connect_autosave_timer() -> void:
	if Game.params["autosave_enabled"]:
		autosave_timer.wait_time = 0.1
		autosave_timer.timeout.connect(_on_timeout)
		autosave_timer.start()


func _on_timeout() -> void:
	_autosave()


func _on_main_ready() -> void:
	_save_entered()


func _on_offline_progress_processed(
	_seconds_delta: int, _worker_progress: Dictionary, _enemy_progress: Dictionary, _factor: float
) -> void:
	_autosave(true, true)
	SignalBus.worker_updated.emit(Game.WORKER_RESOURCE_ID, workers[Game.WORKER_RESOURCE_ID], 0)


##############
## internal ##
##############


func _write(file_name: String) -> void:
	var save_data: Dictionary = _export_save_data()

	_check_backward_corrupt_worker_role(save_data)

	var content: String = JSON.stringify(save_data)
	content += SIGNATURE

	var path: String = FileSystemUtils.USER_PATH + file_name
	var save_file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	save_file.store_line(content)
	save_file.close()


func _read(file_name: String) -> Dictionary:
	var path: String = FileSystemUtils.USER_PATH + file_name
	if Game.params["debug_logs"]:
		print()
		print("__READ_FILE: " + file_name)

	var save_file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if save_file == null:
		if Game.params["debug_logs"]:
			print("__READ_NULL")
		return {}
	var content: String = save_file.get_as_text()
	save_file.close()

	content = _handle_corrupt_end_of_file(content)
	content = content.replace(SIGNATURE, "")
	if Game.params["debug_logs"]:
		print("__READ_CONTENT: " + content)

	var json_object: JSON = _parse(content)
	if json_object == null:
		if Game.params["debug_logs"]:
			print("__READ_PARSE_FAILED")
		return {}
	var save_data: Dictionary = json_object.get_data()

	if Game.params["debug_logs"]:
		print("__READ_DONE")

	return save_data


func _parse(content: String, retry: bool = true) -> JSON:
	var json_object: JSON = JSON.new()
	var parse_err: Error = json_object.parse(content)
	if parse_err != Error.OK:
		if Game.params["debug_logs"]:
			print("__READ_PARSE_ERROR: " + str(parse_err))
		if retry:
			var retry_content: String = StringUtils.sanitize_text(content, StringUtils.ASCII)
			if Game.params["debug_logs"]:
				print("__READ_RETRY_PARSE_WITH_FORCE_ASCII_CONTENT: " + retry_content)
			return _parse(retry_content, false)
		return null
	return json_object


func _replace(file_name: String, old_text: String, new_text: String) -> void:
	var path: String = FileSystemUtils.USER_PATH + file_name
	var save_file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if save_file == null:
		return
	var content: String = save_file.get_as_text()
	save_file.close()

	content = _handle_corrupt_end_of_file(content)
	content = content.replace(old_text, new_text)

	save_file = FileAccess.open(path, FileAccess.WRITE)
	save_file.store_line(content)
	save_file.close()


## removes corrupt excess data from end of save file (underlying OS can fail a FileAccess operation)
func _handle_corrupt_end_of_file(content: String) -> String:
	var signature_index: int = content.find(SIGNATURE)
	if signature_index == -1:
		return content
	var new_content: String = content.substr(0, signature_index + SIGNATURE.length())
	return new_content


func _metadata_save_file_name_internal(value: String) -> String:
	return '"' + "save_file_name" + '"' + ":" + '"' + str(value) + '"'
