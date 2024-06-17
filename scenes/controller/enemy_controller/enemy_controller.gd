extends Node
class_name EnemyController

const ENEMY_CYCLE_SECONDS: int = Game.params["enemy_cycle_seconds"]

@onready var timer: Timer = $Timer

###############
## overrides ##
###############


func _ready() -> void:
	_initialize()
	_connect_signals()


#############
## helpers ##
#############


func _initialize() -> void:
	_start_timer()


func _start_timer() -> void:
	var essence_count: int = SaveFile.get_enemy_ids_for_option(2).size()
	var factor: float = 1.0 - (essence_count * 0.1)
	timer.start(ENEMY_CYCLE_SECONDS * factor)


func _generate() -> void:
	var damage: int = _get_damage()
	SignalBus.enemy_damage.emit(damage, name)


func _get_damage() -> int:
	var swordsman_damage: int = 1 * SaveFile.workers.get("swordsman", 0)
	return swordsman_damage


#############
## signals ##
#############


func _connect_signals() -> void:
	timer.timeout.connect(_on_timeout)
	SignalBus.deaths_door.connect(_on_deaths_door)
	SignalBus.deaths_door_resolved.connect(_on_deaths_door_resolved)


func _on_timeout() -> void:
	_generate()


func _on_deaths_door(enemy_data: EnemyData, option: int) -> void:
	SignalBus.deaths_door_decided.emit(enemy_data, option)


func _on_deaths_door_resolved(
	_enemy_data: EnemyData, _new_enemy_data: EnemyData, _option: int
) -> void:
	_start_timer()
