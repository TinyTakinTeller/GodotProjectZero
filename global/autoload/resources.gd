extends Node

const RESOURCE_GENERATOR: String = "game_data/resource_generator/tres"
const WORKER_ROLE: String = "game_data/worker_role/tres"
const EVENT_DATA: String = "game_data/event_data/tres"
const TAB_DATA: String = "game_data/tab_data/tres"
const NPC_EVENT: String = "game_data/npc_event/tres"
const ENEMY_DATA: String = "game_data/enemy_data/tres"

var resource_generators: Dictionary = FileSystemUtils.get_resources(RESOURCE_GENERATOR, false)
var worker_roles: Dictionary = FileSystemUtils.get_resources(WORKER_ROLE, false)
var event_datas: Dictionary = FileSystemUtils.get_resources(EVENT_DATA, false)
var tab_datas: Dictionary = FileSystemUtils.get_resources(TAB_DATA, false)
var npc_events: Dictionary = FileSystemUtils.get_resources(NPC_EVENT, false)
var enemy_datas: Dictionary = FileSystemUtils.get_resources(ENEMY_DATA, false)

var theme: Dictionary = FileSystemUtils.get_resources("theme", true)
var particle: Dictionary = FileSystemUtils.get_resources("particle", false)

var enemy_image: Dictionary = FileSystemUtils.get_image_resources("enemy", true)


func _ready() -> void:
	if Game.params["debug_logs"]:
		print("_AUTOLOAD _READY: " + self.get_name())
