class_name Game

const VERSION_MAJOR = "pre-alpha"
const VERSION_MINOR = "week 4"

const WORKER_RESOURCE_ID = "worker"

const params: Dictionary = params_prod  #params_prod  #params_debug

const params_debug: Dictionary = {
	"cycle_seconds": 2,
	"house_workers": 4,
	"save_system_enabled": false,
	"autosave_enabled": true,
	"autosave_seconds": 5,
	"timer_firepit_seconds": 1,
	"timer_house_seconds": 1,
	"timer_cat_intro_seconds": 1,
	"animation_speed_diary": 0.1,
	"animation_speed_npc": 0.05,
	"delete_counter": 5,
	"max_file_name_length": 20,
	"debug_cooldown": 1,
	"debug_gift": true,
	"debug_resource_generated_event": false,
	"debug_line_effect": false,
	"debug_no_scrollbar": false,
	"debug_logs": true,
	"default_theme": "dark"
}

const params_prod: Dictionary = {
	"cycle_seconds": 10,
	"house_workers": 4,
	"save_system_enabled": true,
	"autosave_enabled": true,
	"autosave_seconds": 5,
	"timer_firepit_seconds": 10,
	"timer_house_seconds": 5,
	"timer_cat_intro_seconds": 10,
	"animation_speed_diary": 0.1,
	"animation_speed_npc": 0.05,
	"delete_counter": 5,
	"max_file_name_length": 20,
	"debug_cooldown": 0,
	"debug_gift": false,
	"debug_resource_generated_event": false,
	"debug_line_effect": false,
	"debug_no_scrollbar": false,
	"debug_logs": true,
	"default_theme": "dark"
}
