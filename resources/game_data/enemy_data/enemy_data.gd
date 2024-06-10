extends Resource
class_name EnemyData

@export var id: String
@export var health_points: int
@export var enemy_image_id: String
@export var next_enemy_id: String


func get_enemy_image_texture() -> Resource:
	return Resources.enemy_image.get(enemy_image_id, null)


func get_title() -> String:
	var title: String = Locale.get_enemy_data_title(id)
	if StringUtils.is_not_empty(title):
		return title
	return StringUtils.humanify_string(id)


func get_info() -> String:
	return Locale.get_enemy_data_info(id)
