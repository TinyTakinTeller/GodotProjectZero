class_name ShakeShaderComponent extends Node

@export var unique_shader_material: bool = false
@export var max_shake_strength: float = 4.0
@export var offset_shake_strength: float = 0.1
@export var shake_shader: ShaderMaterial

###############
## overrides ##
###############


func _ready() -> void:
	_initialize()
	_load_from_save_file()
	_connect_signals()


#############
## helpers ##
#############


func _initialize() -> void:
	if unique_shader_material:
		shake_shader = shake_shader.duplicate()
		shake_shader.set_shader_parameter("offset_time", randf() * 60.0)
	enable()


func _load_from_save_file() -> void:
	var value: float = SaveFile.effect_settings["shake"]["value"]
	var toggle: float = SaveFile.effect_settings["shake"]["toggle"]
	update_shake_effect(toggle, value)


func _normalize_shake_effect(value: float) -> float:
	return max_shake_strength * (value + offset_shake_strength)


#############
## methods ##
#############


func enable() -> void:
	get_parent().material = shake_shader


func disable() -> void:
	get_parent().material = null


func update_shake_effect(toggle: bool, value: float) -> void:
	if shake_shader != null:
		if toggle:
			shake_shader.set_shader_parameter("Strength", _normalize_shake_effect(value))
		else:
			shake_shader.set_shader_parameter("Strength", 0.0)


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.effect_settings_updated.connect(_on_effect_settings_updated)
	SignalBus.player_death.connect(_on_player_death)


func _on_effect_settings_updated(toggle: bool, value: float, id: String) -> void:
	if id == "shake":
		update_shake_effect(toggle, value)


func _on_player_death() -> void:
	update_shake_effect(false, 0)
