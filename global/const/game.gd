class_name Game

const WORKER_RESOURCE_ID: String = "worker"
const WORKER_ROLE_RESOURCE: Array[String] = [WORKER_RESOURCE_ID, "swordsman"]

const VERSION_MAJOR: String = "prototype"
const VERSION_MINOR: String = "release 1.4"

const PARAMS: Dictionary = PARAMS_PROD  #PARAMS_PROD  #PARAMS_DEBUG

const SKIP_BOSS: bool = false

const PARAMS_DEBUG: Dictionary = {
	"BuH_skip_boss": SKIP_BOSS,
	"BuH_wall_disabled": false,
	"BuH_damage_timer": 0.4,
	"BuH_cat_boss_battle_fps": false,
	"soul_disabled": false,
	"prestige_disabled": false,
	"reborn_overlay_shader": true,
	"heart_screen_shader": true,
	"essence_bonus": 2,
	"spirit_bonus": 2,
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
	"deaths_door_no_info": true,
	"smart_assign_restrict_sergeant": false
}

const PARAMS_PROD: Dictionary = {
	"BuH_skip_boss": SKIP_BOSS,
	"BuH_damage_timer": 0.4,
	"BuH_wall_disabled": false,
	"BuH_cat_boss_battle_fps": false,
	"soul_disabled": false,
	"prestige_disabled": false,
	"reborn_overlay_shader": true,
	"heart_screen_shader": true,
	"essence_bonus": 2,
	"spirit_bonus": 2,
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
	"deaths_door_no_info": true,
	"smart_assign_restrict_sergeant": false
}
