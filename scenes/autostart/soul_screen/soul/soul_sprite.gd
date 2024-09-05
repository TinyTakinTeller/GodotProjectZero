class_name SoulSprite
extends CharacterBody2D

const DELAY: float = 0.1

var min_speed: float = 100

@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var hurtbox_area_2d: Area2D = %HurtboxArea2D

###############
## overrides ##
###############


func _physics_process(_delta: float) -> void:
	if not visible:
		return

	var target_position: Vector2 = get_global_mouse_position()
	var sprite_size: Vector2 = sprite_2d.get_rect().size
	target_position += sprite_2d.get_rect().size / 2

	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	target_position.x = min(max(target_position.x, sprite_size.x), viewport_size.x - sprite_size.x)
	target_position.y = min(max(target_position.y, sprite_size.y), viewport_size.y - sprite_size.y)

	create_tween().tween_property(self, "position", target_position, DELAY)


func _ready() -> void:
	_connect_signals()


#############
## signals ##
#############


func _connect_signals() -> void:
	hurtbox_area_2d.area_entered.connect(_on_hurtbox_area_entered)


func _on_hurtbox_area_entered(_area: Area2D) -> void:
	pass
