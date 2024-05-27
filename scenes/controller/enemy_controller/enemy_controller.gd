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
	timer.wait_time = ENEMY_CYCLE_SECONDS
	timer.start()


func _generate() -> void:
	var damage: int = _get_damage()
	SignalBus.enemy_damage.emit(damage, self.name)


func _get_damage() -> int:
	var swordsman_damage: int = 1 * SaveFile.workers.get("swordsman", 0)
	return swordsman_damage


#############
## signals ##
#############


func _connect_signals() -> void:
	timer.timeout.connect(_on_timeout)


func _on_timeout() -> void:
	_generate()
