class_name PatternMaster
extends Node2D

var _pattern_list: Array = []

@onready var fps: Label = $FPS
@onready var patterns: Node2D = $Patterns
@onready var wall_collision_polygon_2d: CollisionPolygon2D = $Walls/WallCollisionPolygon2D


func _ready() -> void:
	fps.visible = Game.PARAMS["BuH_cat_boss_battle_fps"]
	wall_collision_polygon_2d.disabled = Game.PARAMS["BuH_wall_disabled"]

	for pattern: Node2D in patterns.get_children():
		var spawners: Array = []
		for subpattern: Node2D in pattern.get_children():
			spawners.append(subpattern.get_child(0) as BuHSpawnPoint)
		_pattern_list.append(spawners)
	# print(_pattern_list)


func _process(_delta: float) -> void:
	if Game.PARAMS["BuH_cat_boss_battle_fps"]:
		fps.text = (
			str(Engine.get_frames_per_second()) + " FPS\n" + str(Spawning.poolBullets.size())
		)


func _physics_process(_delta: float) -> void:
	pass


func align_patterns(target: Vector2) -> void:
	for index: int in range(_pattern_list.size()):
		align_pattern(target, index)


func align_pattern(target: Vector2, index: int) -> void:
	for spawner: BuHSpawnPoint in _pattern_list[index]:
		spawner.position = target


func start_pattern(index: int) -> void:
	for spawner: BuHSpawnPoint in _pattern_list[index]:
		spawner.start()


func stop_pattern(index: int) -> void:
	for spawner: BuHSpawnPoint in _pattern_list[index]:
		spawner.stop()
