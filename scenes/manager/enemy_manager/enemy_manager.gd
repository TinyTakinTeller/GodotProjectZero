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
	damage = Limits.safe_add_factor(SaveFile.get_enemy_damage(), damage)

	var total_damage: int = SaveFile.add_enemy_damage(damage)
	SignalBus.enemy_damaged.emit(total_damage, damage, source_id)


func _handle_on_deaths_door_decided(enemy_data: EnemyData, option: int) -> void:
	SaveFile.set_enemy(enemy_data.next_enemy_id, option)

	var enemy_id: String = SaveFile.enemy["level"]
	var new_enemy_data: EnemyData = Resources.enemy_datas.get(enemy_id, null)
	if new_enemy_data == null:
		return
	SignalBus.deaths_door_resolved.emit(enemy_data, new_enemy_data, option)


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.enemy_damage.connect(_on_enemy_damage)
	SignalBus.deaths_door_decided.connect(_on_deaths_door_decided)


func _on_enemy_damage(damage: int, source_id: String) -> void:
	_handle_on_enemy_damage(damage, source_id)


func _on_deaths_door_decided(enemy_data: EnemyData, option: int) -> void:
	_handle_on_deaths_door_decided(enemy_data, option)
