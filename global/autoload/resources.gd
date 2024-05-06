extends Node

var theme: Dictionary = FileSystemUtis.get_resources("theme", true)
var resource_generators: Dictionary = FileSystemUtis.get_resources(
	"game_data/resource_generator", false
)
var worker_roles: Dictionary = FileSystemUtis.get_resources("game_data/worker_role", false)
var event_datas: Dictionary = FileSystemUtis.get_resources("game_data/event_data", false)
var tab_datas: Dictionary = FileSystemUtis.get_resources("game_data/tab_data", false)
