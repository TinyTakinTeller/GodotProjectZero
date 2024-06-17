extends Node

const RESOURCE_GENERATOR: String = "game_data/resource_generator/tres"
const WORKER_ROLE: String = "game_data/worker_role/tres"
const EVENT_DATA: String = "game_data/event_data/tres"
const TAB_DATA: String = "game_data/tab_data/tres"
const NPC_EVENT: String = "game_data/npc_event/tres"
const ENEMY_DATA: String = "game_data/enemy_data/tres"

var resource_generators: Dictionary
var worker_roles: Dictionary
var event_datas: Dictionary
var tab_datas: Dictionary
var npc_events: Dictionary
var enemy_datas: Dictionary

var theme: Dictionary
var particle: Dictionary

var enemy_image: Dictionary


func _ready() -> void:
	resource_generators = FileSystemUtils.get_resources(RESOURCE_GENERATOR, false)
	worker_roles = FileSystemUtils.get_resources(WORKER_ROLE, false)
	event_datas = FileSystemUtils.get_resources(EVENT_DATA, false)
	tab_datas = FileSystemUtils.get_resources(TAB_DATA, false)
	npc_events = FileSystemUtils.get_resources(NPC_EVENT, false)
	enemy_datas = FileSystemUtils.get_resources(ENEMY_DATA, false)

	theme = FileSystemUtils.get_resources("theme", true)
	particle = FileSystemUtils.get_resources("particle", false)

	enemy_image = FileSystemUtils.get_image_resources("enemy", true)

	if Game.params["debug_logs"]:
		print("_AUTOLOAD _READY: " + self.get_name())
		print("enemy_image check...")
		print(enemy_image.size())
		print(enemy_image)
