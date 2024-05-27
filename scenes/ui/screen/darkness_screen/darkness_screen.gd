extends MarginContainer

const TAB_DATA_ID: String = "enemy"

@onready var scroll_container: ScrollContainer = %ScrollContainer
@onready var texture_button: Button = %TextureButton
@onready var texture_rect: TextureRect = %TextureRect
@onready var shader_texture_rect: TextureRect = %ShaderTextureRect
@onready var progress_bar_left: ProgressBar = %ProgressBarLeft
@onready var progress_bar_right: ProgressBar = %ProgressBarRight
@onready var progress_bar_label: Label = %ProgressBarLabel
@onready var shader_simple_tween: SimpleTween = %ShaderSimpleTween
@onready var passive_label_effect_queue: LabelEffectQueue = %PassiveLabelEffectQueue
@onready var click_label_effect_queue: LabelEffectQueue = %ClickLabelEffectQueue
@onready var click_damage_buffer_timer: Timer = %ClickDamageBufferTimer
@onready var texture_margin_container: MarginContainer = %TextureMarginContainer

## tween params
var shader_simple_tween_duration: float = 0.5
var rl_max: float = 6
var rx_max: float = rl_max
var ry_max: float = rl_max

## effect params
var label_color: Color = Color(0.878, 0, 0.392, 1)
var damage_buffer: int = 0
var damage_buffer_time: float = 0.15
var particle_id: String = "enemy_damage_particle"

var _enemy_data: EnemyData

###############
## overrides ##
###############


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		_propagate_theme_to_virtual_children()


func _ready() -> void:
	_initialize()
	_connect_signals()


#############
## helpers ##
#############


func _propagate_theme_to_virtual_children() -> void:
	var inherited_theme: Resource = NodeUtils.get_inherited_theme(self)
	if passive_label_effect_queue != null:
		passive_label_effect_queue.set_theme(inherited_theme)
		passive_label_effect_queue.set_color_theme_override(label_color)
	if click_label_effect_queue != null:
		click_label_effect_queue.set_theme(inherited_theme)
		click_label_effect_queue.set_color_theme_override(label_color)


func _initialize() -> void:
	_propagate_theme_to_virtual_children()
	_load_enemy()
	_play_shader_simple_tween_animation(0)
	ScrollContainerUtils.disable_scrollbars(scroll_container)
	passive_label_effect_queue.set_particle(particle_id)
	click_label_effect_queue.set_particle(particle_id)
	click_damage_buffer_timer.wait_time = damage_buffer_time
	click_damage_buffer_timer.start()


func _load_enemy() -> void:
	var enemy_id: String = SaveFile.enemy["level"]
	var enemy_data: EnemyData = Resources.enemy_datas.get(enemy_id, null)
	if enemy_data == null:
		return
	_enemy_data = enemy_data

	var texture: Resource = _enemy_data.get_enemy_image_texture()
	_set_texture(texture)

	var total_damage: int = SaveFile.get_enemy_damage(enemy_id)
	_update_health_bar(total_damage)


func _set_texture(texture: Resource) -> void:
	if texture == null:
		return
	texture_rect.texture = texture
	shader_texture_rect.texture = texture


func _update_health_bar(total_damage: int) -> void:
	if _enemy_data == null:
		return
	var health_points: int = _enemy_data.health_points

	var value: int = max(0, health_points - total_damage)
	var percent: float = (value as float) / (health_points as float)
	progress_bar_left.value = percent
	progress_bar_right.value = percent
	progress_bar_label.text = NumberUtils.format_number(value)


func _update_pivot() -> void:
	self.set_pivot_offset(Vector2(self.size.x / 2, self.size.y / 2))
	passive_label_effect_queue.position.x = (
		self.get_rect().size.x / 2 + texture_margin_container.get_rect().size.x / 4
	)
	passive_label_effect_queue.position.y = (
		self.get_rect().size.y / 2 - texture_margin_container.get_rect().size.y / 4
	)
	click_label_effect_queue.position.x = (self.get_rect().size.x / 2)
	click_label_effect_queue.position.y = (self.get_rect().size.y / 2)


###############
## animation ##
###############


func _play_click_damage_effect(damage: int) -> void:
	click_label_effect_queue.add_task("- %s" % NumberUtils.format_number(damage))


func _play_damage_effect(damage: int) -> void:
	passive_label_effect_queue.add_task("- %s" % NumberUtils.format_number(damage))


func _play_burst_damage_effect(damage: int, burst: int) -> void:
	var part_damage: int = damage / burst
	var last_part_without_round_error: int = damage - (part_damage * (burst - 1))
	for i: int in range(burst - 1):
		_play_damage_effect(part_damage)
	_play_damage_effect(last_part_without_round_error)


func _play_shader_simple_tween_animation(duration: float = shader_simple_tween_duration) -> void:
	if shader_simple_tween.is_finished():
		_randomize_shader_simple_tween_direction()
		shader_simple_tween.play_animation_(duration)


func _randomize_shader_simple_tween_direction() -> void:
	var random_direction: Vector2 = Vector2(0, rl_max).rotated(randf_range(0, deg_to_rad(360)))
	rx_max = random_direction.x
	ry_max = random_direction.y


#############
## signals ##
#############


func _connect_signals() -> void:
	self.resized.connect(_on_resized)
	texture_button.button_down.connect(_on_texture_button_down)
	texture_button.mouse_entered.connect(_on_mouse_entered)
	click_damage_buffer_timer.timeout.connect(_on_click_damage_buffer_timer_timeout)
	SignalBus.tab_changed.connect(_on_tab_changed)
	SignalBus.enemy_damaged.connect(_on_enemy_damaged)


func _on_resized() -> void:
	_update_pivot()


func _on_texture_button_down() -> void:
	var damage: int = SaveFile.resources.get("experience", 0)
	if Game.params["enemy_click_damage"] != 1:
		damage = randi() % Game.params["enemy_click_damage"]

	SignalBus.enemy_damage.emit(damage, self.name)


func _on_mouse_entered() -> void:
	SignalBus.enemy_hover.emit(_enemy_data)


func _on_click_damage_buffer_timer_timeout() -> void:
	if damage_buffer != 0:
		_play_click_damage_effect(damage_buffer)
		damage_buffer = 0


func _on_tab_changed(tab_data: TabData) -> void:
	if tab_data.id == TAB_DATA_ID:
		visible = true
	else:
		visible = false


func _on_enemy_damaged(total_damage: int, damage: int, source_id: String) -> void:
	if damage <= 0:
		return

	_play_shader_simple_tween_animation()
	_update_health_bar(total_damage)

	if source_id == "EnemyController":
		_play_damage_effect(damage)
	else:
		damage_buffer += damage


############
## export ##
############


func _shader_simple_tween(animation_percent: float) -> void:
	var rx: float
	var ry: float
	if animation_percent < 0.5:
		rx = 0 + (animation_percent * 2 * rx_max)
		ry = 0 + (animation_percent * 2 * ry_max)
	else:
		rx = ((1 - animation_percent) * 2 * rx_max)
		ry = ((1 - animation_percent) * 2 * ry_max)
	shader_texture_rect.material.set_shader_parameter("r_displacement", [0, 0])
	shader_texture_rect.material.set_shader_parameter("b_displacement", [rx, ry])
	shader_texture_rect.material.set_shader_parameter("g_displacement", [rx, ry])
