class_name EnemyController
extends Node

const ENEMY_CYCLE_SECONDS: float = Game.PARAMS["enemy_cycle_seconds"]

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


func get_cycle_duration() -> float:
	return ENEMY_CYCLE_SECONDS


#############
## helpers ##
#############


func _initialize() -> void:
	_start_timer()


func _start_timer() -> void:
	timer.start(get_cycle_duration())


func _generate() -> void:
	var damage: int = _get_damage()
	SignalBus.enemy_damage.emit(damage, name)


func _get_damage() -> int:
	var ratio: int = Game.PARAMS["spirit_bonus"]
	var spirit_count: int = SaveFile.get_spirit_substance_count()
	var swordsman: int = SaveFile.workers.get("swordsman", 0)
	var swordsman_damage: int = max(
		Limits.safe_mult(swordsman, spirit_count + ratio) / ratio,
		Limits.safe_mult(swordsman, max(1, (spirit_count + ratio) / ratio))
	)
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
	if !enemy_data.is_last():
		var substance_id: String = ("essence_" if option == 1 else "spirit_") + str(enemy_data.id)
		SignalBus.substance_generated.emit(substance_id)

	SignalBus.deaths_door_decided.emit(enemy_data, option)


func _on_deaths_door_resolved(
	_enemy_data: EnemyData, _new_enemy_data: EnemyData, _option: int
) -> void:
	_start_timer()
