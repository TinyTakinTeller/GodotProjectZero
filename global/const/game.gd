class_name Game

const WORKER_RESOURCE_ID: String = "worker"
const WORKER_ROLE_RESOURCE: Array[String] = [WORKER_RESOURCE_ID, "swordsman"]

const VERSION_MAJOR: String = "pre-alpha"
const VERSION_MINOR: String = "week 8"

const params: Dictionary = params_prod  #params_prod  #params_debug

const params_debug: Dictionary = {
	"cycle_seconds": 2,
	"enemy_cycle_seconds": 3,
	"enemy_click_damage": -10,
	"house_workers": 4,
	"save_system_enabled": true,
	"autosave_enabled": true,
	"autosave_seconds": 5,
	"timer_firepit_seconds": 1,
	"timer_cat_intro_seconds": 1,
	"animation_speed_diary": 0.09,
	"animation_speed_npc": 0.05,
	"delete_counter": 5,
	"max_file_name_length": 20,
	"debug_cooldown": 1,
	"debug_gift": true,
	"debug_resource_generated_event": false,
	"debug_line_effect": false,
	"debug_no_scrollbar": false,
	"debug_logs": true,
	"debug_free_resource_buttons": true,
	"default_theme": "dark",
	"resource_storage_info": false,
	"deaths_door_no_info": true
}

const params_prod: Dictionary = {
	"cycle_seconds": 5,
	"enemy_cycle_seconds": 3,
	"enemy_click_damage": 0,
	"house_workers": 4,
	"save_system_enabled": true,
	"autosave_enabled": true,
	"autosave_seconds": 5,
	"timer_firepit_seconds": 10,
	"timer_cat_intro_seconds": 10,
	"animation_speed_diary": 0.09,
	"animation_speed_npc": 0.05,
	"delete_counter": 5,
	"max_file_name_length": 20,
	"debug_cooldown": 0,
	"debug_gift": false,
	"debug_resource_generated_event": false,
	"debug_line_effect": false,
	"debug_no_scrollbar": false,
	"debug_logs": true,
	"debug_free_resource_buttons": false,
	"default_theme": "dark",
	"resource_storage_info": false,
	"deaths_door_no_info": true
}
