#gdlint:ignore = max-public-methods
extends Node

const LOCALES: Array[String] = ["en", "fr", "pt", "pl", "zh", "th"]
const LOCALE_NAME: Dictionary = {
	"en": "English",
	"fr": "Français",
	"pt": "Português (BR)",
	"pl": "polski",
	"zh": "中文",
	"th": "ไทย"
}


func _ready() -> void:
	pass


func get_key(prefix: String, id: String) -> String:
	return prefix + ":" + id


func get_localized_text(category: String, id: String) -> String:
	var key: String = get_key(category, id)
	var translation: String = tr(key)
	if translation == key:
		translation = ""
	if StringUtils.is_empty(translation):
		return "?"
	return translation


func get_localized_array(category: String, id: String) -> Array:
	var json: JSON = JSON.new()
	var key: String = get_key(category, id)
	var raw_string: String = tr(key)
	var result: Error = json.parse(raw_string)

	if result == Error.OK:
		var result_data: Variant = json.data
		return result_data
	push_warning("Failed to fetch localized array for '%s' as: " % [key], raw_string)
	return []


func get_credit_label(id: String) -> String:
	return get_localized_text("credit", id)


func get_role_label(id: String) -> String:
	return get_localized_text("role", id)


func get_ui_label(id: String) -> String:
	return get_localized_text("ui_label", id)


func get_npc_hover_info(npc_id: String) -> String:
	return get_localized_text("npc_hover_info", npc_id)


func get_npc_hover_title(npc_id: String) -> String:
	return get_localized_text("npc_hover_title", npc_id)


func get_npc_click_info(npc_id: String) -> String:
	return get_localized_text("npc_click_info", npc_id)


func get_npc_click_title(npc_id: String) -> String:
	return get_localized_text("npc_click_title", npc_id)


func get_scale_settings_info(scale: int) -> String:
	return get_localized_text("scale_settings_info", str(scale))


func get_enemy_data_info(enemy_id: String) -> String:
	return get_localized_text("enemy_data_info", enemy_id)


func get_enemy_data_option_title(enemy_id: String, option: int) -> String:
	return get_localized_text("enemy_data_option_title", enemy_id + "-" + str(option))


func get_enemy_data_title(enemy_id: String) -> String:
	return get_localized_text("enemy_data_title", enemy_id)


func get_resource_generator_label(resource_id: String) -> String:
	return get_localized_text("resource_generator_label", resource_id)


func get_resource_generator_title(resource_id: String) -> String:
	return get_localized_text("resource_generator_title", resource_id)


func get_resource_generator_flavor(resource_id: String) -> String:
	return get_localized_text("resource_generator_flavor", resource_id)


func get_resource_generator_max_flavor(resource_id: String) -> String:
	return get_localized_text("resource_generator_max_flavor", resource_id)


func get_resource_generator_display_name(resource_id: String) -> String:
	return get_localized_text("resource_generator_display_name", resource_id)


func get_worker_role_title(role_id: String) -> String:
	return get_localized_text("worker_role_title", role_id)


func get_worker_role_flavor(role_id: String) -> String:
	return get_localized_text("worker_role_flavor", role_id)


func get_tab_data_titles(tab_id: String) -> Array:
	return get_localized_array("tab_data_titles", tab_id)


func get_event_data_text(event_id: String) -> String:
	return get_localized_text("event_data_text", event_id)


func get_npc_event_text(event_id: String) -> String:
	return get_localized_text("npc_event_text", event_id)


func get_npc_event_options(event_id: String) -> Array:
	return get_localized_array("npc_event_options", event_id)


func get_substance_text(id: String) -> String:
	return get_localized_text("substance_text", id)


func get_substance_category_text(id: String) -> String:
	return get_localized_text("substance_category_text", id)
