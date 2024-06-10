extends MarginContainer

const TAB_DATA_ID: String = "enemy"

@onready var title_label: Label = %TitleLabel
@onready var texture_scroll_container: ScrollContainer = %TextureScrollContainer
@onready var texture_button: Button = %TextureButton
@onready var texture_rect: TextureRect = %TextureRect
@onready var damage_shader_texture_rect: TextureRect = %DamageShaderTextureRect
@onready var boss_progress_bar_margin_container: MarginContainer = %BossProgressBarMarginContainer
@onready var progress_bar_left: ProgressBar = %ProgressBarLeft
@onready var progress_bar_right: ProgressBar = %ProgressBarRight
@onready var progress_bar_label: Label = %ProgressBarLabel
@onready var shader_simple_tween: SimpleTween = %ShaderSimpleTween
@onready var passive_label_effect_queue: LabelEffectQueue = %PassiveLabelEffectQueue
@onready var click_label_effect_queue: LabelEffectQueue = %ClickLabelEffectQueue
@onready var click_damage_buffer_timer: Timer = %ClickDamageBufferTimer
@onready var texture_margin_container: MarginContainer = %TextureMarginContainer
@onready var choice_h_box_container: HBoxContainer = %ChoiceHBoxContainer
@onready var first_choice_button: Button = %FirstChoiceButton
@onready var second_choice_button: Button = %SecondChoiceButton
@onready var padding_margin_container: MarginContainer = %PaddingMarginContainer
@onready var texture_pixel_explosion: TexturePixelExplosion = %TexturePixelExplosion
@onready var title_margin_container: MarginContainer = %TitleMarginContainer

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
var death_animation_duration: float = 1.0
var death_animation_end_delay: float = 0.5

var _enemy_data: EnemyData
var _health: int
var _deaths_door_option: int = 0
var _explosion_state: int = 0

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
	_set_ui_labels()
	_propagate_theme_to_virtual_children()
	_load_enemy()
	_play_shader_simple_tween_animation(0)

	ScrollContainerUtils.disable_scrollbars(texture_scroll_container)
	passive_label_effect_queue.set_particle(particle_id)

	click_label_effect_queue.set_particle(particle_id)
	click_damage_buffer_timer.wait_time = damage_buffer_time
	click_damage_buffer_timer.start()

	texture_pixel_explosion.visible = false
	texture_pixel_explosion.get_simple_tween().duration = death_animation_duration
	texture_pixel_explosion.get_simple_tween().end_delay = death_animation_end_delay
	#texture_pixel_explosion.get_simple_tween().round_about = true


func _set_ui_labels() -> void:
	var ui_deaths_door_first: String = Locale.get_ui_label("deaths_door_first")
	var ui_deaths_door_second: String = Locale.get_ui_label("deaths_door_second")
	first_choice_button.text = ui_deaths_door_first
	second_choice_button.text = ui_deaths_door_second


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
	damage_shader_texture_rect.texture = texture


func _update_health_bar(total_damage: int = -1) -> void:
	if _enemy_data == null:
		return
	var health_points: int = _enemy_data.health_points

	if total_damage != -1:
		var value: int = max(0, health_points - total_damage)
		_health = value

	var percent: float = (_health as float) / (health_points as float)
	progress_bar_left.value = percent
	progress_bar_right.value = percent
	progress_bar_label.text = NumberUtils.format_number(_health)

	if _health == 0:
		_deaths_door_enabled()
	else:
		_deaths_door_disabled()


func _deaths_door_enabled() -> void:
	_health_visibility(false)
	_choice_visibility(true)
	title_label.text = Locale.get_ui_label("deaths_door")
	#title_label.modulate = Color(0.878, 0, 0.392, 1)
	#texture_rect.material.set_shader_parameter("Strength", 20)
	texture_rect.modulate.a = 0.5  #Color(0.878, 0, 0.392, 0.5)
	damage_shader_texture_rect.visible = false


func _deaths_door_disabled() -> void:
	_health_visibility(true)
	_choice_visibility(false)
	title_label.text = Locale.get_enemy_data_title(_enemy_data.id)
	#title_label.modulate = Color.WHITE
	#texture_rect.material.set_shader_parameter("Strength", 1)
	texture_rect.modulate = Color.WHITE
	damage_shader_texture_rect.visible = true


func _health_visibility(visible_: bool) -> void:
	boss_progress_bar_margin_container.visible = visible_


func _choice_visibility(visible_: bool) -> void:
	choice_h_box_container.visible = visible_


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
	click_label_effect_queue.add_task("- %s" % NumberUtils.format_number_scientific(damage))


func _play_damage_effect(damage: int) -> void:
	passive_label_effect_queue.add_task("- %s" % NumberUtils.format_number_scientific(damage))


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


##############
## handlers ##
##############


func _handle_choice_button(choice: int) -> void:
	texture_rect.visible = false
	title_margin_container.visible = false
	choice_h_box_container.visible = false

	_deaths_door_option = choice
	texture_pixel_explosion.texture = texture_rect.texture
	_explosion_state = 0
	texture_pixel_explosion.play_animation()
	texture_pixel_explosion.visible = true


func _handle_on_texture_pixel_explosion_finished() -> void:
	if _explosion_state == 0:
		SignalBus.deaths_door.emit(_enemy_data, _deaths_door_option)
		return

	texture_pixel_explosion.visible = false
	texture_rect.visible = true
	title_margin_container.visible = true
	choice_h_box_container.visible = true

	_load_enemy()
	_update_health_bar(0)


func _handle_on_on_deaths_door_resolved(enemy_data: EnemyData) -> void:
	_enemy_data = enemy_data
	var texture: Resource = _enemy_data.get_enemy_image_texture()
	texture_pixel_explosion.texture = texture
	_explosion_state = 1
	texture_pixel_explosion.play_animation(true)


#############
## signals ##
#############


func _connect_signals() -> void:
	self.resized.connect(_on_resized)
	texture_button.button_down.connect(_on_texture_button_down)
	texture_button.mouse_entered.connect(_on_mouse_entered)
	padding_margin_container.mouse_entered.connect(_on_mouse_entered)
	click_damage_buffer_timer.timeout.connect(_on_click_damage_buffer_timer_timeout)
	SignalBus.tab_changed.connect(_on_tab_changed)
	SignalBus.enemy_damaged.connect(_on_enemy_damaged)
	first_choice_button.mouse_entered.connect(_on_first_choice_button_hover)
	second_choice_button.mouse_entered.connect(_on_second_choice_button_hover)
	first_choice_button.mouse_exited.connect(_on_choice_button_unhover.bind(first_choice_button))
	second_choice_button.mouse_exited.connect(_on_choice_button_unhover.bind(second_choice_button))
	first_choice_button.button_down.connect(_on_first_choice_button_down)
	second_choice_button.button_down.connect(_on_second_choice_button_down)
	texture_pixel_explosion.get_simple_tween().animation_finished.connect(
		_on_texture_pixel_explosion_finished
	)
	SignalBus.deaths_door_resolved.connect(_on_deaths_door_resolved)


func _on_resized() -> void:
	_update_pivot()


## calling _on_mouse_entered() here because mobile users don't have mouse_entered signal
func _on_texture_button_down() -> void:
	_on_mouse_entered()
	if _health == 0:
		return

	var damage: int = SaveFile.resources.get("experience", 0)
	if Game.params["enemy_click_damage"] != 1:
		damage = randi() % Game.params["enemy_click_damage"]

	SignalBus.enemy_damage.emit(damage, self.name)


func _on_mouse_entered() -> void:
	if _health == 0:
		SignalBus.info_hover_shader.emit(
			Locale.get_ui_label("deaths_door_title"), Locale.get_ui_label("deaths_door_info")
		)
	else:
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
	if damage <= 0 or _health == 0:
		return

	_play_shader_simple_tween_animation()
	_update_health_bar(total_damage)

	if source_id == "EnemyController":
		_play_damage_effect(damage)
	else:
		damage_buffer += damage


func _on_first_choice_button_hover() -> void:
	first_choice_button.modulate = Color(0.878, 0.0, 0.392)
	SignalBus.info_hover.emit(
		Locale.get_ui_label("deaths_door_first_title"),
		Locale.get_ui_label("deaths_door_first_info")
	)


func _on_second_choice_button_hover() -> void:
	second_choice_button.modulate = Color(0.392, 0.878, 0.0)
	SignalBus.info_hover.emit(
		Locale.get_ui_label("deaths_door_second_title"),
		Locale.get_ui_label("deaths_door_second_info")
	)


func _on_choice_button_unhover(button: Button) -> void:
	button.modulate = Color.WHITE


func _on_first_choice_button_down() -> void:
	first_choice_button.release_focus()
	## _handle_choice_button(1) ## TODO: Souls Tab & More Enemies


func _on_second_choice_button_down() -> void:
	second_choice_button.release_focus()
	## _handle_choice_button(2)  ## TODO: Souls Tab & More Enemies


func _on_texture_pixel_explosion_finished() -> void:
	_handle_on_texture_pixel_explosion_finished()


func _on_deaths_door_resolved(enemy_data: EnemyData, _option: int) -> void:
	_handle_on_on_deaths_door_resolved(enemy_data)


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
	damage_shader_texture_rect.material.set_shader_parameter("r_displacement", [0, 0])
	damage_shader_texture_rect.material.set_shader_parameter("b_displacement", [rx, ry])
	damage_shader_texture_rect.material.set_shader_parameter("g_displacement", [rx, ry])
