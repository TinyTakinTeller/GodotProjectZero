extends Resource
class_name EnemyData

@export var id: String
@export var title: String
@export var health_points: int
@export var enemy_image_id: String
@export var info: String


func get_enemy_image_texture() -> Resource:
	return Resources.enemy_image.get(enemy_image_id, null)


func get_title() -> String:
	if title != null:
		return title
	return StringUtils.humanify_string(id)


func get_info() -> String:
	return info
