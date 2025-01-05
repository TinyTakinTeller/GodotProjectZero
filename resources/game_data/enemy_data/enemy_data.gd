class_name EnemyData
extends Resource

@export var order: int = 0
@export var id: String
@export var health_points: int
@export var enemy_image_id: String
@export var enemy_icon_id: String
@export var next_enemy_id: String
@export var column: int = 0


func get_sort_value() -> int:
	return order


func get_enemy_image_texture() -> Resource:
	return Resources.image.get(enemy_image_id, null)


func get_enemy_icon_texture() -> Resource:
	return Resources.image.get(enemy_icon_id, null)


func get_title() -> String:
	return Locale.get_enemy_data_title(id)


func get_enemy_data_option_title(option: int) -> String:
	return Locale.get_enemy_data_option_title(id, option)


func get_info() -> String:
	return Locale.get_enemy_data_info(id)


func is_last() -> bool:
	return id == next_enemy_id


static func order_less_than(a: EnemyData, b: EnemyData) -> bool:
	return a.order < b.order


static func order_greater_than(a: EnemyData, b: EnemyData) -> bool:
	return a.order > b.order
