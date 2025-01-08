extends Node

signal save_file_imported(save_file_name: String)

const SIGNATURE = "$$$"
const SAVE_FILE_EXTENSION = ".json"
const AUTOSAVE_SECONDS: int = Game.PARAMS["autosave_seconds"]

var prestige_dialog: bool = false
var prestige_dialog_timestamp: Dictionary = {}
var cat_sprite_2d_position: Vector2 = Vector2.ZERO

var active_file_name: String = "default"
var save_datas: Dictionary = {}
var default_save_data: Dictionary = {}

var resources: Dictionary = {}
var workers: Dictionary = {}
var substances: Dictionary = {}
var events: Dictionary = {}
var event_log: Dictionary = {}
var resource_generator_unlocks: Array = ["land"]
var worker_role_unlocks: Array = []
var tab_unlocks: Array = ["world", "settings"]
var tab_levels: Dictionary = {"world": 0}
var settings: Dictionary = {
	"theme": "dark", "display_mode": "windowed", "display_resolution": [960, 540]
}
var audio_settings: Dictionary = {
	"master": {"value": 1.00, "toggle": true},
	"music": {"value": 0.80, "toggle": true},
	"sfx": {"value": 0.50, "toggle": true}
}
var effect_settings: Dictionary = {
	"shake": {"value": 0.20, "toggle": true}, "typing": {"value": 0.40, "toggle": true}
}
var npc_events: Dictionary = {}
var enemy: Dictionary = {"level": "rabbit", "rabbit": {"damage": 0}}
var metadata: Dictionary = {}
var locale: String = "en"
var _last_locale: String = "en"

@onready var autosave_timer: Timer = %AutosaveTimer

###############
## overrides ##
###############


func _ready() -> void:
	default_save_data = _export_save_data()

	_load_save_files()
	_connect_signals()

	locale = get_locale_from_newest_save_file()
	TranslationServer.set_locale(locale)
	_last_locale = locale

	if Game.PARAMS["debug_logs"]:
		print("_AUTOLOAD _READY: " + self.get_name())


#############
## getters ##
#############


func get_locale_from_newest_save_file() -> String:
	var max_unix_time: int = 0
	var max_save_file_name: String = ""
	for save_file_name: String in save_datas:
		var save_data: Dictionary = save_datas[save_file_name]
		var save_metadata: Dictionary = _get_metadata(save_data)
		var metadata_last_utc_time: Dictionary = save_metadata.get("last_utc_time", null)
		if metadata_last_utc_time != null:
			var unix_time: int = Time.get_unix_time_from_datetime_dict(metadata_last_utc_time)
			if unix_time > max_unix_time:
				max_unix_time = unix_time
				max_save_file_name = save_file_name
	if max_save_file_name != "":
		var default_locale: String = save_datas[max_save_file_name].get("LOCALE", "en")
		return default_locale
	return "en"


func get_prestige_count() -> int:
	return get_heart_substance_count()


func get_heart_substance_count() -> int:
	return SaveFile.substances.get("heart", 0)


func get_cycle_seconds() -> float:
	var cycle_seconds: float = Game.PARAMS["cycle_seconds"]

	var has_empress: bool = SaveFile.substances.get("the_empress", 0) > 0
	if has_empress:
		cycle_seconds *= 0.5

	return cycle_seconds


func get_enemy_cycle_seconds() -> float:
	var cycle_seconds: float = Game.PARAMS["enemy_cycle_seconds"]

	var has_chariot: bool = SaveFile.substances.get("the_chariot", 0) > 0
	if has_chariot:
		cycle_seconds *= 0.5

	return cycle_seconds


func get_house_workers() -> int:
	var house_workers: int = Game.PARAMS["house_workers"]

	var has_tower: bool = SaveFile.substances.get("the_tower", 0) > 0
	if has_tower:
		house_workers *= 2

	return house_workers


func get_shadow_percent() -> int:
	var heart: int = SaveFile.substances.get("heart", 0)
	var flesh: int = SaveFile.substances.get("flesh", 0)
	var eye: int = SaveFile.substances.get("eye", 0)
	var bone: int = SaveFile.substances.get("bone", 0)
	return (heart * 100) + (flesh * 1) + (eye * 5) + (bone * 50)


func scale_by_shadows(id: String, amount: int, percent: int = -1) -> int:
	if amount <= 0:
		return amount

	var resource_generator: ResourceGenerator = Resources.resource_generators.get(id, null)
	var unique: bool = false if resource_generator == null else resource_generator.is_unique()
	if (
		id not in ["singularity", "experience"]
		and id not in Game.WORKER_ROLE_RESOURCE
		and not unique
	):
		if percent < 0:
			percent = SaveFile.get_shadow_percent() + 100
		return max(
			max(
				Limits.safe_mult(amount, percent) / 100,
				Limits.safe_mult(amount, max(1, percent / 10)) / 10
			),
			Limits.safe_mult(amount, max(1, percent / 100))
		)
	return amount


func get_spirit_substance_count() -> int:
	return get_substance_count_by_category("spirit")


func get_essence_substance_count() -> int:
	return get_substance_count_by_category("essence")


func get_substance_count_by_category(category: String) -> int:
	var count: int = 0
	for substance_id: String in Resources.substance_datas:
		var spirit_data: SubstanceData = Resources.substance_datas[substance_id]
		if spirit_data.get_category_id() == category:
			count += substances.get(substance_id, 0)
	return count


func get_enemy_option(id: String, save_file_enemy: Dictionary = enemy) -> int:
	if id == "angel":
		return 0

	var first: int = save_file_enemy.get(id, {}).get("option", {}).get("1", 0)
	var second: int = save_file_enemy.get(id, {}).get("option", {}).get("2", 0)
	if first == 0 and second == 0:
		return 0
	return 1 if first > second else 2


func get_enemy_ids(save_file_enemy: Dictionary = enemy) -> Array:
	return save_file_enemy.keys().filter(
		func(id: String) -> bool: return id != "level" and get_enemy_option(id) > 0
	)


func get_enemy_ids_for_option(option: int, save_file_enemy: Dictionary = enemy) -> Array:
	return save_file_enemy.keys().filter(
		func(id: String) -> bool: return (
			id != "level" and get_enemy_option(id, save_file_enemy) == option
		)
	)


func get_enemy_damage(enemy_id: String = "") -> int:
	if enemy_id == "":
		enemy_id = SaveFile.enemy.get("level", "NULL")

	var enemy_progression: Dictionary = SaveFile.enemy.get(enemy_id, {})
	var enemy_damage: int = enemy_progression.get("damage", 0)
	return enemy_damage


func get_enemy_data(enemy_id: String = "") -> EnemyData:
	if enemy_id == "":
		enemy_id = SaveFile.enemy.get("level", "NULL")

	return Resources.enemy_datas.get(enemy_id, null)


func get_settings_theme(save_file_name: String) -> Resource:
	var theme_id: String = Game.PARAMS["default_theme"]
	if !save_datas.has(save_file_name):
		return Resources.theme.get(theme_id, null)

	var save_data: Dictionary = save_datas[save_file_name]
	var saved_settings: Dictionary = save_data.get("settings", {})
	theme_id = saved_settings.get("theme", "")
	return Resources.theme.get(theme_id, null)


func get_settings_population_scale() -> int:
	return settings.get("population_scale", 1)


func is_typing_effect_enabled() -> bool:
	return (
		effect_settings.get("typing", {}).get("toggle", false)
		and effect_settings.get("typing", {}).get("value", 0.0) > 0.0
	)


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


#############
## methods ##
#############


func last_prestige_time() -> Dictionary:
	var default_timestamp: Dictionary = metadata.get("first_utc_time", {})
	var timestamp: Dictionary = metadata.get("last_prestige_timestamp", default_timestamp)
	return timestamp


func current_prestige_time(now: Dictionary = Time.get_datetime_dict_from_system(true)) -> String:
	return DateTimeUtils.format_duration(last_prestige_time(), now, false)


func best_prestige_time() -> String:
	var result: String = DateTimeUtils.format_duration(
		metadata.get("best_prestige_start_timestamp", {}),
		metadata.get("best_prestige_end_timestamp", {}),
		false
	)
	return result if result != "0s" else "NAN"


func best_prestige_delta() -> int:
	return DateTimeUtils.unix_delta(
		metadata.get("best_prestige_start_timestamp", {}),
		metadata.get("best_prestige_end_timestamp", {})
	)


func prestige(infinity_count: int) -> void:
	var first_time: bool = SaveFile.get_prestige_count() == 0
	if infinity_count <= 0:
		push_error("[save_file]: PRESTIGE - Invalid infinity count " + str(infinity_count))
		return

	autosave_timer.stop()

	# backup save file data (keep: before first prestige and before last prestige)
	var backup_file_name: String = active_file_name + ".BAK_FIRST"
	if not first_time:
		backup_file_name = active_file_name + ".BAK_LAST"
	_update_metadata()
	var save_data: Dictionary = _export_save_data()
	_write(backup_file_name, save_data)

	# prestige save file data
	#
	# keep immortal resources only & grant singularities
	var keep_experience: int = resources.get("experience", 0) + 1
	var keep_soulstone: int = resources.get("soulstone", 0)
	var keep_singularity: int = resources.get("singularity", 0) + infinity_count
	resources = {
		"soulstone": keep_soulstone, "singularity": keep_singularity, "experience": keep_experience
	}
	#
	# keep all substances & grant heart
	substances["heart"] = substances.get("heart", 0) + 1
	#
	# keep settings and metadata
	# settings["population_scale"] = 1 # (except scale)
	#
	# save timestamp delta record
	if prestige_dialog_timestamp.is_empty():
		push_warning("prestige_dialog_timestamp was not set!")
		prestige_dialog_timestamp = Time.get_datetime_dict_from_system(true)
	var delta: int = DateTimeUtils.unix_delta(last_prestige_time(), prestige_dialog_timestamp)
	var best_delta: int = best_prestige_delta()
	var is_best: bool = first_time or delta < best_delta
	if is_best:
		metadata["best_prestige_start_timestamp"] = last_prestige_time()
		metadata["best_prestige_end_timestamp"] = prestige_dialog_timestamp
	metadata["last_prestige_timestamp"] = Time.get_datetime_dict_from_system(true)
	#
	# clear else
	workers = {}
	events = {}
	event_log = {}
	resource_generator_unlocks = ["land"]
	worker_role_unlocks = []
	tab_unlocks = ["world", "settings"]
	tab_levels = {"world": 0}
	npc_events = {}
	enemy = {"level": "rabbit", "rabbit": {"damage": 0}}

	# write save file data
	var file_name: String = active_file_name
	_update_metadata()
	save_data = _export_save_data()
	_write(file_name, save_data)

	# autosave_timer.start()


func export_as_string(save_file_name: String) -> String:
	var target_data: Dictionary = save_datas[save_file_name]
	var json_string: String = JSON.stringify(target_data)
	var encoded_save_file: String = Marshalls.utf8_to_base64(json_string)
	return encoded_save_file


func import_from_string(encoded_string: String) -> bool:
	if Game.PARAMS["debug_logs"]:
		prints("Try import...", encoded_string)
	var decoded_save_file: String = Marshalls.base64_to_utf8(encoded_string)
	if decoded_save_file == null:
		return false
	var json_object: JSON = _parse(decoded_save_file)
	if json_object == null:
		if Game.PARAMS["debug_logs"]:
			prints("__IMPORT_READ_PARSE_FAILED", decoded_save_file)
		return false
	var import_save_data: Dictionary = json_object.get_data()

	var save_file_name: String = import_save_data.get("metadata", {}).get("save_file_name")
	if save_file_name:
		while SaveFile.save_datas.has(save_file_name):
			save_file_name = StringUtils.increment_int_suffix(
				save_file_name, SaveFile.save_datas.keys()
			)
			import_save_data["metadata"]["save_file_name"] = save_file_name
		save_datas[save_file_name] = import_save_data
		save_file_imported.emit(save_file_name)
		return true

	return false


###########
## setup ##
###########


func initialize(save_file_name: String, metadata_name: String) -> void:
	if !Game.PARAMS["save_system_enabled"]:
		return

	var file_name: String = save_file_name + SAVE_FILE_EXTENSION
	active_file_name = file_name

	if save_datas.has(save_file_name):
		var save_data: Dictionary = save_datas[save_file_name]
		if save_data != null and !save_data.is_empty():
			_import_save_data(save_data)
	elif StringUtils.is_not_empty(metadata_name):
		var save_data: Dictionary = default_save_data.duplicate()
		_import_save_data(save_data)
		metadata["save_file_name"] = metadata_name

		if _last_locale != locale:
			TranslationServer.set_locale(_last_locale)
			SaveFile.locale = _last_locale
			SignalBus.display_language_updated.emit()


func post_initialize() -> void:
	prestige_dialog = false
	_connect_autosave_timer()


func delete(save_file_name: String) -> void:
	var file_name: String = save_file_name + SAVE_FILE_EXTENSION
	var error: Error = DirAccess.remove_absolute(FileSystemUtils.USER_PATH + file_name)
	if Game.PARAMS["debug_logs"]:
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
	var save_data: Dictionary = _export_save_data()
	_write(file_name, save_data)


func _get_seconds_since_last_autosave() -> int:
	var now_time: Dictionary = Time.get_datetime_dict_from_system(true)
	var last_time: Dictionary = metadata.get("last_utc_time", now_time)
	var unix_delta: int = (
		Time.get_unix_time_from_datetime_dict(now_time)
		- Time.get_unix_time_from_datetime_dict(last_time)
	)
	return unix_delta


func _load_save_files() -> void:
	if !Game.PARAMS["save_system_enabled"]:
		return

	for file_name: String in FileSystemUtils.get_user_files():
		if !file_name.ends_with(SAVE_FILE_EXTENSION):
			if Game.PARAMS["debug_logs"]:
				print("__SKIP_SAVE_DATA: " + file_name)
			continue
		var save_data: Dictionary = _read(file_name)
		_check_backward_compatibility(save_data)
		if Game.PARAMS["debug_logs"]:
			print("__LOAD_SAVE_DATA: " + file_name)
			# print(save_data)
		if save_data == null or save_data.is_empty():
			continue
		var save_file_name: String = file_name.trim_suffix(SAVE_FILE_EXTENSION)
		save_datas[save_file_name] = save_data


func _export_save_data() -> Dictionary:
	var save_data: Dictionary = {}
	save_data["resources"] = resources
	save_data["workers"] = workers
	save_data["substances"] = substances
	save_data["events"] = events
	save_data["event_log"] = event_log
	save_data["resource_generator_unlocks"] = resource_generator_unlocks
	save_data["worker_role_unlocks"] = worker_role_unlocks
	save_data["tab_unlocks"] = tab_unlocks
	save_data["tab_levels"] = tab_levels
	save_data["settings"] = settings
	save_data["audio_settings"] = audio_settings
	save_data["effect_settings"] = effect_settings
	save_data["npc_events"] = npc_events
	save_data["enemy"] = enemy
	save_data["metadata"] = metadata
	save_data["LOCALE"] = locale
	return save_data


func _import_save_data(save_data: Dictionary) -> void:
	resources = _get_resources(save_data)
	workers = _get_workers(save_data)
	substances = _get_substances(save_data)
	events = _get_events(save_data)
	event_log = _get_event_log(save_data)
	resource_generator_unlocks = _get_resource_generator_unlocks(save_data)
	worker_role_unlocks = _get_worker_role_unlocks(save_data)
	tab_unlocks = _get_tab_unlocks(save_data)
	tab_levels = _get_tab_levels(save_data)
	settings = _get_settings(save_data)
	audio_settings = _get_audio_settings(save_data)
	effect_settings = _get_effect_settings(save_data)
	npc_events = _get_npc_events(save_data)
	enemy = _get_enemy(save_data)
	metadata = _get_metadata(save_data)
	locale = _get_locale(save_data)

	if not locale in TranslationServer.get_loaded_locales():
		push_warning("Unsupported locale in save file: %s" % [locale])
		locale = "en"
	TranslationServer.set_locale(locale)


func _get_resources(save_data: Dictionary) -> Dictionary:
	return save_data.get("resources", resources)


func _get_workers(save_data: Dictionary) -> Dictionary:
	return save_data.get("workers", workers)


func _get_substances(save_data: Dictionary) -> Dictionary:
	return save_data.get("substances", substances)


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


func _get_effect_settings(save_data: Dictionary) -> Dictionary:
	return save_data.get("effect_settings", effect_settings)


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


func _get_save_file_name(save_data: Dictionary) -> String:
	return save_data["metadata"].get("save_file_name", "")


func _check_backward_compatibility(save_data: Dictionary) -> void:
	_check_backward_week_5(save_data)
	_check_backward_week_7(save_data)
	_check_backward_week_10(save_data)
	_check_backward_week_11(save_data)
	_check_backward_week_15(save_data)

	check_backward_corrupt_worker_role(save_data)


## migrating Substances from enemies to proper substances
## 1. replace soul tab with substance tab
## 2. migrate enemy choices to proper substances
func _check_backward_week_15(save_data: Dictionary) -> void:
	var save_file_tab_unlocks: Array = save_data.get("tab_unlocks", {})
	var index: int = save_file_tab_unlocks.find("soul")
	if index != -1:
		save_file_tab_unlocks[index] = "substance"
		save_data["tab_unlocks"] = save_file_tab_unlocks

	var save_file_enemy: Dictionary = save_data.get("enemy", {})
	var save_file_substances: Dictionary = save_data.get("substances", {})
	if save_file_substances.is_empty():
		var spirits: Array = get_enemy_ids_for_option(2, save_file_enemy)
		for spirit: String in spirits:
			save_file_substances["spirit_" + spirit] = 1
		var essences: Array = get_enemy_ids_for_option(1, save_file_enemy)
		for essence: String in essences:
			save_file_substances["essence_" + essence] = 1
	save_data["substances"] = save_file_substances


func _check_backward_week_11(save_data: Dictionary) -> void:
	if !save_data["settings"].has("display_mode"):
		save_data["settings"]["display_mode"] = settings["display_mode"]
	if !save_data["settings"].has("display_resolution"):
		save_data["settings"]["display_resolution"] = settings["display_resolution"]


## [WORKAROUND] for #ADF-27 | https://trello.com/c/7VNXK6xW
func check_backward_corrupt_worker_role(save_data: Dictionary) -> void:
	if save_data == null or save_data.is_empty():
		save_data = _export_save_data()

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
		if Game.PARAMS["debug_logs"]:
			print(
				(
					"[WORKAROUND] workers error: "
					+ str(error)
					+ " : "
					+ str(total_roles)
					+ " / "
					+ str(worker_resources)
					+ " at "
					+ _get_save_file_name(save_data)
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
	var target_version: Array[String] = ["week 3", "week 4", "week 5", "week 6", "week 7"]
	var last_version: String = save_data.get("metadata", {}).get("last_version_minor", "")
	if !target_version.has(last_version):
		return

	var check_enemy: String = save_data.get("enemy", {}).get("level", "")
	if check_enemy == "" or check_enemy == "ambassador":
		save_data["enemy"] = {"level": "rabbit", "rabbit": {"damage": 0}}


## cat dialogue tree was extended in week 6, this resets the last answer so dialogue can continue
func _check_backward_week_5(save_data: Dictionary) -> void:
	var target_version: Array[String] = ["week 3", "week 4", "week 5"]
	var last_version: String = save_data.get("metadata", {}).get("last_version_minor", "")
	if !target_version.has(last_version):
		return

	var cat_events: Dictionary = save_data.get("npc_events", {}).get("cat", {})
	if cat_events.get("cat_intro", 0) != 0:
		cat_events["cat_intro"] = -1

	save_data.get("metadata", {})["last_version_minor"] = Game.VERSION_MINOR


##############
## signals ##
##############


func _connect_signals() -> void:
	SignalBus.main_ready.connect(_on_main_ready)
	SignalBus.offline_progress_processed.connect(_on_offline_progress_processed)

	# autosave_timer.stop()
	autosave_timer.timeout.connect(_on_timeout)


func _connect_autosave_timer() -> void:
	if Game.PARAMS["autosave_enabled"]:
		autosave_timer.wait_time = 0.1  # timer interval, check autosave interval in timer event
		autosave_timer.start()


func _on_timeout() -> void:
	_autosave()


func _on_main_ready() -> void:
	_save_entered()


func _on_offline_progress_processed(
	_seconds_delta: int,
	_worker_progress: Dictionary,
	_enemy_progress: Dictionary,
	_factor: float,
	_death_progress: Dictionary
) -> void:
	_autosave(true, true)
	SignalBus.worker_updated.emit(
		Game.WORKER_RESOURCE_ID, workers.get(Game.WORKER_RESOURCE_ID, 0), 0
	)


##############
## internal ##
##############


func _write(file_name: String, data: Dictionary) -> void:
	check_backward_corrupt_worker_role(data)

	var content: String = JSON.stringify(data)
	content += SIGNATURE

	var path: String = FileSystemUtils.USER_PATH + file_name
	var save_file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	save_file.store_line(content)
	save_file.close()

	if Game.PARAMS["debug_logs"]:
		print("[save_file] _write: '" + file_name + "'")


func _read(file_name: String) -> Dictionary:
	var path: String = FileSystemUtils.USER_PATH + file_name
	if Game.PARAMS["debug_logs"]:
		print()
		print("__READ_FILE: " + file_name)

	var save_file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if save_file == null:
		if Game.PARAMS["debug_logs"]:
			print("__READ_NULL")
		return {}
	var content: String = save_file.get_as_text()
	save_file.close()

	content = _handle_corrupt_end_of_file(content)
	content = content.replace(SIGNATURE, "")
	#if Game.PARAMS["debug_logs"]:
	#	print("__READ_CONTENT: " + content)

	var json_object: JSON = _parse(content)
	if json_object == null:
		if Game.PARAMS["debug_logs"]:
			prints("__READ_PARSE_FAILED", content)
		return {}
	var save_data: Dictionary = json_object.get_data()

	if Game.PARAMS["debug_logs"]:
		print("__READ_DONE")

	return save_data


func _parse(content: String, retry: bool = true) -> JSON:
	var json_object: JSON = JSON.new()
	var parse_err: Error = json_object.parse(content)
	if parse_err != Error.OK:
		if Game.PARAMS["debug_logs"]:
			print("__READ_PARSE_ERROR: " + str(parse_err))
		if retry:
			var retry_content: String = StringUtils.sanitize_text(content, StringUtils.ASCII)
			if Game.PARAMS["debug_logs"]:
				prints("__READ_RETRY_PARSE_WITH_FORCE_ASCII_CONTENT: ", retry_content)
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
