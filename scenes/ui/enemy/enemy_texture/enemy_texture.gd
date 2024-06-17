extends MarginContainer
class_name EnemyTexture

@onready var texture_rect: TextureRect = %TextureRect
@onready var texture_rgb_offset: TextureRgbOffset = %TextureRgbOffset
@onready var texture_pixel_explosion: TexturePixelExplosion = %TexturePixelExplosion
@onready var texture_button: Button = %TextureButton

###############
## overrides ##
###############


func _ready() -> void:
	_initialize()


###########
## setup ##
###########


func set_enemy_texture(texture: Resource) -> void:
	if texture == null:
		return
	texture_rect.texture = texture
	texture_rgb_offset.texture = texture
	texture_pixel_explosion.texture = texture


func set_fast_mode(fast: bool) -> void:
	texture_pixel_explosion.set_fast_mode(fast)


func update_display_mode(disabled: bool) -> void:
	if disabled:
		modulate.a = 0.5
		_display_mode(1, 1, 0, 0)
	else:
		modulate.a = 1.0
		_display_mode(1, 1, 0, 1)


func _initialize() -> void:
	_display_mode(0, 0, 0, 0)
	set_fast_mode(false)


############
## helper ##
############


func _display_mode(rect: bool, rgb_offset: bool, pixel_explosion: bool, button: bool) -> void:
	texture_rect.visible = rect
	texture_rgb_offset.visible = rgb_offset
	texture_pixel_explosion.visible = pixel_explosion
	texture_button.visible = button


###############
## animation ##
###############


func play_damage_animation() -> void:
	_display_mode(1, 1, 0, 1)
	texture_rgb_offset.play_animation()


func play_explosion_animation() -> void:
	_display_mode(0, 0, 1, 0)
	texture_pixel_explosion.play_animation()


func play_reverse_explosion_animation() -> void:
	_display_mode(0, 0, 1, 0)
	texture_pixel_explosion.play_reverse_animation()
