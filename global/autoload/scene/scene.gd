extends Node

const MAIN_SCENE: PackedScene = preload("res://scenes/autostart/main/main.tscn")
const SAVE_FILE_PICKER_SCENE: PackedScene = preload(
	"res://scenes/autostart/save_file_picker/save_file_picker.tscn"
)
const SOUL_SCENE: PackedScene = preload("res://scenes/autostart/soul_screen/soul_screen.tscn")
const END_SCENE: PackedScene = preload("res://scenes/autostart/end/end.tscn")

const SCENE_MAP: Dictionary = {
	"main_scene": MAIN_SCENE,
	"save_file_picker_scene": SAVE_FILE_PICKER_SCENE,
	"soul_scene": SOUL_SCENE,
	"end_scene": END_SCENE
}


func change_scene(scene_id: String) -> void:
	var packed_scene: PackedScene = SCENE_MAP.get(scene_id, null)
	if packed_scene:
		_load_scene(packed_scene)
		if scene_id == "main_scene":
			SaveFile.post_initialize()
	else:
		_handle_error("No scene with id: " + scene_id)


func _load_scene(packed_scene: PackedScene) -> void:
	if packed_scene == null:
		_handle_error("Invalid scene to load")
		return
	get_tree().change_scene_to_packed.call_deferred(packed_scene)


func _handle_error(message: String) -> void:
	push_error(message)
