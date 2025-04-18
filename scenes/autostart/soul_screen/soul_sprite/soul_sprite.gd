class_name SoulSprite
extends CharacterBody2D

const SOUL_SIZE: Vector2 = Vector2(24, 24)  #Vector2(16, 16)

const DELAY: float = 0.1

var min_speed: float = 100
var immortal: bool = false

@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var hurtbox_area_2d: Area2D = %HurtboxArea2D
@onready var damage_timer: Timer = %DamageTimer
@onready var damage_tween: SimpleTween = %DamageTween

###############
## overrides ##
###############


func _physics_process(_delta: float) -> void:
	if not visible:
		return

	var target_position: Vector2 = get_global_mouse_position()
	var sprite_size: Vector2 = SOUL_SIZE  #sprite_2d.get_rect().size
	#target_position += SOUL_SIZE  #sprite_2d.get_rect().size / 2

	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	target_position.x = (
		min(max(target_position.x, sprite_size.x), viewport_size.x - sprite_size.x)
		- (SOUL_SIZE.x) * 0
	)
	target_position.y = (
		min(max(target_position.y, sprite_size.y), viewport_size.y - sprite_size.y)
		- (SOUL_SIZE.y) * 0
	)

	create_tween().tween_property(self, "position", target_position, DELAY)


func _ready() -> void:
	_connect_signals()
	_initialize()

	sprite_2d.scale = SOUL_SIZE / sprite_2d.get_rect().size


func _initialize() -> void:
	damage_timer.wait_time = Game.PARAMS["BuH_damage_timer"]
	damage_tween.duration = Game.PARAMS["BuH_damage_timer"]


#############
## signals ##
#############


func _connect_signals() -> void:
	hurtbox_area_2d.area_entered.connect(_on_hurtbox_area_entered)


func _on_hurtbox_area_entered(_area: Area2D) -> void:
	if immortal:
		return

	if damage_timer.is_stopped():
		damage_timer.start()
		damage_tween.play_animation()
		SignalBus.player_damaged.emit()
		Audio.play_sfx_id("enemy_click_" + str(randi() % 4 + 1))


#############
## exports ##
#############


func _damage_tween_method(percent: float) -> void:
	self.modulate.a = percent
