extends Node

@export var shake_shader_component_scene: PackedScene

@onready var node_2d: Node2D = %Node2D
@onready var pattern_master: PatternMaster = $Node2D/PatternMaster
@onready var soul_sprite: SoulSprite = %SoulSprite
@onready var cat_sprite_2d: Sprite2D = %CatSprite2D

@onready var control: Control = %Control
@onready var label: Label = $Control/Label

###############
## overrides ##
###############


func _physics_process(_delta: float) -> void:
	pattern_master.align_patterns(cat_sprite_2d.position)


func _ready() -> void:
	_initialize()
	_intro_animation()


#############
## helpers ##
#############


func _intro_animation() -> void:
	var cat_sprite_2d_size: Vector2 = cat_sprite_2d.get_rect().size
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var target_position: Vector2 = viewport_size / 2
	target_position.y = cat_sprite_2d_size.y + 16

	var tween: Tween = create_tween()
	tween.finished.connect(_intro_animation_end)
	(
		tween
		. tween_property(cat_sprite_2d, "position", target_position, 2.0)
		. set_ease(Tween.EASE_IN_OUT)
		. set_trans(Tween.TRANS_CUBIC)
	)


func _add_shake_effect_to_cat() -> void:
	var shake_shader_component: ShakeShaderComponent = (
		shake_shader_component_scene.instantiate() as ShakeShaderComponent
	)
	cat_sprite_2d.add_child(shake_shader_component)


func _initialize() -> void:
	cat_sprite_2d.position = SaveFile.cat_sprite_2d_position
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	soul_sprite.position = node_2d.get_global_mouse_position()


#############
## signals ##
#############


func _intro_animation_end() -> void:
	_add_shake_effect_to_cat()
	pattern_master.start_pattern(0)
	pattern_master.start_pattern(1)
