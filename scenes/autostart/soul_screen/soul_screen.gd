extends Node

@export var shake_shader_component_scene: PackedScene

var hp: int = 9
var clicks: int = 0
var boss_cycle: int = 0
var boss_pattern: int = 0
var max_boss_pattern: int = 3

@onready var node_2d: Node2D = %Node2D
@onready var pattern_master: PatternMaster = $Node2D/PatternMaster
@onready var soul_sprite: SoulSprite = %SoulSprite
@onready var cat_sprite_2d: Sprite2D = %CatSprite2D

@onready var control: Control = %Control
@onready var label: Label = %Label

@onready var boss_click_simple_tween: SimpleTween = $BossClickSimpleTween

###############
## overrides ##
###############


func _physics_process(_delta: float) -> void:
	pattern_master.align_patterns(cat_sprite_2d.position)


func _ready() -> void:
	_connect_signals()
	_initialize()
	_intro_animation()

	SignalBus.boss_start.emit()


#############
## helpers ##
#############


func _update_label() -> void:
	label.text = "HP : {0} | DMG: {1}".format({"0": hp, "1": clicks})


func _update_hp(delta: int) -> void:
	hp = hp + delta
	_update_label()


func _update_clicks(delta: int) -> void:
	clicks = clicks + delta
	_update_label()


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


func _connect_signals() -> void:
	SignalBus.player_damaged.connect(_on_player_damaged)
	SignalBus.boss_click.connect(_on_boss_click)
	SignalBus.boss_cycle.connect(_on_boss_cycle)
	SignalBus.boss_end.connect(_on_boss_end)


func _intro_animation_end() -> void:
	_add_shake_effect_to_cat()
	pattern_master.start_pattern(boss_pattern)


func _on_player_damaged() -> void:
	_update_hp(-1)
	if hp <= 0:
		SignalBus.player_death.emit()
		get_tree().paused = true


func _on_boss_click() -> void:
	_update_clicks(1)
	boss_click_simple_tween.play_animation()


func _on_boss_cycle() -> void:
	if Game.PARAMS["BuH_skip_boss"]:
		pattern_master.stop_pattern(boss_pattern)
		SignalBus.boss_end.emit()
		return

	boss_cycle += 1
	if boss_cycle % 3 == 0:
		if boss_pattern < max_boss_pattern:
			pattern_master.stop_pattern(boss_pattern)
			boss_pattern = (boss_pattern + 1)
			pattern_master.start_pattern(boss_pattern)
		elif boss_pattern == max_boss_pattern:
			pattern_master.stop_pattern(boss_pattern)
			SignalBus.boss_end.emit()


func _on_boss_end() -> void:
	label.visible = false
	boss_click_simple_tween.duration = 1.0
	boss_click_simple_tween.loop = true
	boss_click_simple_tween.play_animation()


############
## export ##
############


func _boss_click_simple_tween(percent: float) -> void:
	cat_sprite_2d.modulate.g = percent
	cat_sprite_2d.modulate.b = percent
