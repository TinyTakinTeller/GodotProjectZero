extends Node2D

@onready var spawn_point_1: Node2D = $Circle1/SpawnPoint
@onready var spawn_point_2: Node2D = $Circle2/SpawnPoint


func _process(_delta):
	$FPS.text = str(Engine.get_frames_per_second()) + " FPS\n" + str(Spawning.poolBullets.size())


func _on_PlayerTest_area_shape_entered(
	_area_rid: RID, _area: Area2D, _area_shape_index: int, _local_shape_index: int
) -> void:
	pass
