extends Node

const locale: Dictionary = {"en": LocaleEn.en}
const locale_name: Dictionary = {"en": "English"}


func get_ui_label(id: String) -> String:
	return locale[SaveFile.LOCALE]["ui_label"].get(id, "")


func get_npc_hover_info(npc_id: String) -> String:
	return locale[SaveFile.LOCALE]["npc_hover_info"].get(npc_id, "")


func get_npc_hover_title(npc_id: String) -> String:
	return locale[SaveFile.LOCALE]["npc_hover_title"].get(
		npc_id, StringUtils.humanify_string(npc_id)
	)


func get_npc_click_info(npc_id: String) -> String:
	return locale[SaveFile.LOCALE]["npc_click_info"].get(npc_id, "")


func get_npc_click_title(npc_id: String) -> String:
	return locale[SaveFile.LOCALE]["npc_click_title"].get(
		npc_id, StringUtils.humanify_string(npc_id)
	)


func get_scale_settings_info(scale_: int) -> String:
	return locale[SaveFile.LOCALE]["scale_settings_info"].get(
		scale_, locale[SaveFile.LOCALE]["scale_settings_info"][-1]
	)


func get_enemy_data_info(enemy_id: String) -> String:
	return locale[SaveFile.LOCALE]["enemy_data_info"].get(enemy_id, "")


func get_enemy_data_title(enemy_id: String) -> String:
	return locale[SaveFile.LOCALE]["enemy_data_title"].get(
		enemy_id, StringUtils.humanify_string(enemy_id)
	)


func get_resource_generator_label(resource_id: String) -> String:
	return locale[SaveFile.LOCALE]["resource_generator_label"].get(
		resource_id, StringUtils.humanify_string(resource_id)
	)


func get_resource_generator_title(resource_id: String) -> String:
	return locale[SaveFile.LOCALE]["resource_generator_title"].get(
		resource_id, StringUtils.humanify_string(resource_id)
	)


func get_resource_generator_flavor(resource_id: String) -> String:
	return locale[SaveFile.LOCALE]["resource_generator_flavor"].get(resource_id, "")


func get_resource_generator_max_flavor(resource_id: String) -> String:
	return locale[SaveFile.LOCALE]["resource_generator_max_flavor"].get(resource_id, "")


func get_resource_generator_display_name(resource_id: String) -> String:
	return locale[SaveFile.LOCALE]["resource_generator_display_name"].get(
		resource_id, StringUtils.humanify_string(resource_id)
	)


func get_worker_role_title(role_id: String) -> String:
	return locale[SaveFile.LOCALE]["worker_role_title"].get(
		role_id, StringUtils.humanify_string(role_id)
	)


func get_worker_role_flavor(role_id: String) -> String:
	return locale[SaveFile.LOCALE]["worker_role_flavor"].get(role_id, "")


func get_tab_data_titles(tab_id: String) -> Array:
	return locale[SaveFile.LOCALE]["tab_data_titles"].get(tab_id, [])


func get_event_data_text(event_id: String) -> String:
	return locale[SaveFile.LOCALE]["event_data_text"].get(event_id, "")


func get_npc_event_text(event_id: String) -> String:
	return locale[SaveFile.LOCALE]["npc_event_text"].get(event_id, "")


func get_npc_event_options(event_id: String) -> Array:
	return locale[SaveFile.LOCALE]["npc_event_options"].get(event_id, [])
