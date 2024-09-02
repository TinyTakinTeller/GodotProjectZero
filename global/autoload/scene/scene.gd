extends Node

@export var main_scene: PackedScene
@export var save_file_picker_scene: PackedScene
@export var soul_scene: PackedScene


func change_scene(scene_id: String) -> void:
	if scene_id == "main_scene":
		change_packed_scene(main_scene)
		SaveFile.post_initialize()
	elif scene_id == "save_file_picker_scene":
		change_packed_scene(save_file_picker_scene)
	elif scene_id == "soul_scene":
		change_packed_scene(soul_scene)
	else:
		push_error("No scene with id: " + scene_id)


func change_packed_scene(packed_scene: PackedScene) -> void:
	get_tree().change_scene_to_packed.call_deferred(packed_scene)
