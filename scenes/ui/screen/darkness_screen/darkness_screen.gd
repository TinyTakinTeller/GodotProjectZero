extends MarginContainer

const TAB_DATA_ID: String = "enemy"

@onready var title_margin_container: MarginContainer = %TitleMarginContainer
@onready var title_label: Label = %TitleLabel
@onready var level_label: Label = %LevelLabel

@onready var passive_label_effect_queue: LabelEffectQueue = %PassiveLabelEffectQueue
@onready var click_label_effect_queue: LabelEffectQueue = %ClickLabelEffectQueue
@onready var click_damage_buffer_timer: Timer = %ClickDamageBufferTimer
@onready var soul_label_effect_queue: LabelEffectQueue = %SoulLabelEffectQueue

@onready var choice_h_box_container: HBoxContainer = %ChoiceHBoxContainer
@onready var first_choice_button: Button = %FirstChoiceButton
@onready var second_choice_button: Button = %SecondChoiceButton
@onready var padding_margin_container: MarginContainer = %PaddingMarginContainer

@onready var enemy_texture: EnemyTexture = %EnemyTexture
@onready var enemy_progress_bar: EnemyProgressBar = %EnemyProgressBar

## effect params
var label_color: Color = ColorSwatches.RED
var soul_color: Color = ColorSwatches.YELLOW
var damage_buffer: int = 0
var damage_buffer_time: float = 0.15
var particle_id: String = "enemy_damage_particle"

## enemy params
var _enemy_data: EnemyData
var _health: int
var _deaths_door_option: int = 0
var _explosion_state: int = 0
var _overkill: int = 0

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


func _initialize() -> void:
	_set_ui_labels()
	_propagate_theme_to_virtual_children()
	_load_enemy()

	passive_label_effect_queue.set_particle(particle_id)
	click_label_effect_queue.set_particle(particle_id)
	soul_label_effect_queue.set_particle(particle_id)
	click_damage_buffer_timer.wait_time = damage_buffer_time
	click_damage_buffer_timer.start()


func _load_enemy() -> void:
	var enemy_id: String = SaveFile.enemy["level"]
	var enemy_data: EnemyData = Resources.enemy_datas.get(enemy_id, null)
	if enemy_data == null:
		return
	_enemy_data = enemy_data

	var texture: Resource = _enemy_data.get_enemy_image_texture()
	enemy_texture.set_enemy_texture(texture)
	enemy_texture.set_fast_mode(_enemy_data.is_last())
	enemy_texture.modulate = Color.WHITE

	var total_damage: int = SaveFile.get_enemy_damage(enemy_id)
	_update_health_bar(total_damage)

	level_label.visible = false
	var total_soulstone: int = ResourceManager.get_total_generated("soulstone")
	if _enemy_data.is_last() and total_soulstone > 0:
		var level: int = total_soulstone + 1
		level_label.text = " " + RomanNumeralUtils.to_roman_numeral(level) + " "
		level_label.visible = true


func _set_ui_labels() -> void:
	var ui_deaths_door_first: String = Locale.get_ui_label("deaths_door_first")
	var ui_deaths_door_second: String = Locale.get_ui_label("deaths_door_second")
	first_choice_button.text = ui_deaths_door_first
	second_choice_button.text = ui_deaths_door_second


func _update_health_bar(total_damage: int) -> void:
	if _enemy_data == null:
		return
	var health_points: int = _enemy_data.health_points
	var value: int = max(0, health_points - total_damage)
	_health = value
	_overkill = total_damage / health_points
	if value == 0 and _enemy_data.is_last():
		SignalBus.resource_generated.emit("soulstone", _overkill, name)

	var percent: float = (_health as float) / (health_points as float)
	enemy_progress_bar.set_display(percent, _health)

	var is_deaths_door: bool = _health == 0
	enemy_texture.update_display_mode(is_deaths_door)
	if is_deaths_door:
		SignalBus.deaths_door_open.emit(_enemy_data)
		_deaths_door_enabled()
	else:
		_deaths_door_disabled()


func _deaths_door_enabled() -> void:
	enemy_progress_bar.visible = false
	choice_h_box_container.visible = true
	title_label.text = Locale.get_ui_label("deaths_door")
	if _enemy_data.is_last():
		if _overkill > 1:
			SignalBus.deaths_door.emit(_enemy_data, _deaths_door_option)
			_load_enemy()
			enemy_texture.modulate.a = 0.5
			enemy_progress_bar.set_display(0, 0)
		else:
			_handle_choice_button(0)


func _deaths_door_disabled() -> void:
	enemy_progress_bar.visible = true
	choice_h_box_container.visible = false
	title_label.text = Locale.get_enemy_data_title(_enemy_data.id)


func _update_pivot() -> void:
	self.set_pivot_offset(Vector2(self.size.x / 2, self.size.y / 2))
	passive_label_effect_queue.position.x = (
		self.get_rect().size.x / 2 + enemy_texture.get_rect().size.x / 4
	)
	passive_label_effect_queue.position.y = (
		self.get_rect().size.y / 2 - enemy_texture.get_rect().size.y / 4
	)
	click_label_effect_queue.position.x = (self.get_rect().size.x / 2)
	click_label_effect_queue.position.y = (self.get_rect().size.y / 2)
	soul_label_effect_queue.position.x = (self.get_rect().size.x / 2)
	soul_label_effect_queue.position.y = (self.get_rect().size.y / 2)


func _propagate_theme_to_virtual_children() -> void:
	var inherited_theme: Resource = NodeUtils.get_inherited_theme(self)
	if passive_label_effect_queue != null:
		passive_label_effect_queue.set_theme(inherited_theme)
		passive_label_effect_queue.set_color_theme_override(label_color)
	if click_label_effect_queue != null:
		click_label_effect_queue.set_theme(inherited_theme)
		click_label_effect_queue.set_color_theme_override(label_color)
	if soul_label_effect_queue != null:
		soul_label_effect_queue.set_theme(inherited_theme)
		soul_label_effect_queue.set_color_theme_override(soul_color)


#############
## effects ##
#############


func _play_soulstone_effect(amount: int) -> void:
	var soulstone: ResourceGenerator = Resources.resource_generators["soulstone"]
	soul_label_effect_queue.add_task(soulstone.get_display_increment(amount))


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


##############
## handlers ##
##############


func _handle_on_texture_button_down() -> void:
	if _health == 0:
		return
	var damage: int = SaveFile.resources.get("experience", 0)

	if Game.params["enemy_click_damage"] > 0:
		damage = Game.params["enemy_click_damage"]
	elif Game.params["enemy_click_damage"] < 0:
		damage = _enemy_data.health_points / (Game.params["enemy_click_damage"] * -1)
	else:
		var essence_count: int = SaveFile.get_enemy_ids_for_option(1).size()
		var swordsman_count: int = SaveFile.workers.get("swordsman", 0)
		var substance_damage: int = (essence_count * swordsman_count) / 5
		damage += substance_damage

	SignalBus.enemy_damage.emit(damage, name)


func _handle_on_enemy_damaged(total_damage: int, damage: int, source_id: String) -> void:
	if damage <= 0 or _health == 0:
		return
	enemy_texture.play_damage_animation()
	_update_health_bar(total_damage)

	if source_id == "EnemyController":
		_play_damage_effect(damage)
	else:
		damage_buffer += damage


func _handle_on_click_damage_buffer_timer_timeout() -> void:
	if damage_buffer != 0:
		_play_click_damage_effect(damage_buffer)
		damage_buffer = 0


func _handle_choice_button(choice: int) -> void:
	title_margin_container.visible = false
	choice_h_box_container.visible = false
	_deaths_door_option = choice
	_explosion_state = 0
	enemy_texture.play_explosion_animation()


func _handle_on_on_deaths_door_resolved(enemy_data: EnemyData) -> void:
	_enemy_data = enemy_data
	_explosion_state = 1
	var texture: Resource = _enemy_data.get_enemy_image_texture()
	enemy_texture.set_enemy_texture(texture)
	enemy_texture.play_reverse_explosion_animation()


func _handle_on_texture_pixel_explosion_finished() -> void:
	if _explosion_state == 0:
		SignalBus.deaths_door.emit(_enemy_data, _deaths_door_option)
		return
	title_margin_container.visible = true
	choice_h_box_container.visible = true
	_load_enemy()
	if visible:
		_on_mouse_entered()


#############
## signals ##
#############


func _connect_signals() -> void:
	self.resized.connect(_on_resized)
	SignalBus.tab_changed.connect(_on_tab_changed)
	enemy_texture.texture_button.mouse_entered.connect(_on_mouse_entered)
	padding_margin_container.mouse_entered.connect(_on_mouse_entered)

	enemy_texture.texture_button.button_down.connect(_on_texture_button_down)
	click_damage_buffer_timer.timeout.connect(_on_click_damage_buffer_timer_timeout)
	SignalBus.enemy_damaged.connect(_on_enemy_damaged)

	first_choice_button.mouse_entered.connect(_on_first_choice_button_hover)
	second_choice_button.mouse_entered.connect(_on_second_choice_button_hover)
	first_choice_button.mouse_exited.connect(_on_choice_button_unhover.bind(first_choice_button))
	second_choice_button.mouse_exited.connect(_on_choice_button_unhover.bind(second_choice_button))
	first_choice_button.button_down.connect(_on_first_choice_button_down)
	second_choice_button.button_down.connect(_on_second_choice_button_down)
	SignalBus.deaths_door_resolved.connect(_on_deaths_door_resolved)
	enemy_texture.texture_pixel_explosion.get_simple_tween().animation_finished.connect(
		_on_texture_pixel_explosion_finished
	)

	SignalBus.resource_generated.connect(_on_resource_generated)


func _on_resized() -> void:
	_update_pivot()


func _on_tab_changed(tab_data: TabData) -> void:
	if tab_data.id == TAB_DATA_ID:
		visible = true
	else:
		visible = false


func _on_mouse_entered() -> void:
	if !Game.params["deaths_door_no_info"] and _health == 0:
		SignalBus.info_hover_shader.emit(
			Locale.get_ui_label("deaths_door_title"), Locale.get_ui_label("deaths_door_info")
		)
		return
	SignalBus.enemy_hover.emit(_enemy_data)


## calling _on_mouse_entered() here because mobile users don't have mouse_entered signal
func _on_texture_button_down() -> void:
	_on_mouse_entered()
	_handle_on_texture_button_down()


func _on_click_damage_buffer_timer_timeout() -> void:
	_handle_on_click_damage_buffer_timer_timeout()


func _on_enemy_damaged(total_damage: int, damage: int, source_id: String) -> void:
	_handle_on_enemy_damaged(total_damage, damage, source_id)


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
	_handle_choice_button(1)


func _on_second_choice_button_down() -> void:
	second_choice_button.release_focus()
	_handle_choice_button(2)


func _on_deaths_door_resolved(
	_old_enemy_data: EnemyData, new_enemy_data: EnemyData, _option: int
) -> void:
	_handle_on_on_deaths_door_resolved(new_enemy_data)


func _on_texture_pixel_explosion_finished() -> void:
	_handle_on_texture_pixel_explosion_finished()


func _on_resource_generated(id: String, amount: int, _source_id: String) -> void:
	if id == "soulstone":
		_play_soulstone_effect(amount)
