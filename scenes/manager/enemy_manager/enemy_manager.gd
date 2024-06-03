extends Node
class_name EnemyManager

###############
## overrides ##
###############


func _ready() -> void:
	_connect_signals()


##############
## handlers ##
##############


func _handle_on_enemy_damage(damage: int, source_id: String) -> void:
	damage = Limits.check_global_max_amount(SaveFile.add_enemy_damage(damage), damage)

	var total_damage: int = SaveFile.add_enemy_damage(damage)
	SignalBus.enemy_damaged.emit(total_damage, damage, source_id)


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.enemy_damage.connect(_on_enemy_damage)


func _on_enemy_damage(damage: int, source_id: String) -> void:
	_handle_on_enemy_damage(damage, source_id)
