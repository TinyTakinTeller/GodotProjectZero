extends Node

var _infinity_count: int = -1

@onready var main_control: Control = %MainControl
@onready var tab_tracker: TabTracker = %TabTracker
@onready var main_ui: Control = %MainUI
@onready var prestige_ui: PrestigeUI = %PrestigeUI
@onready var reborn_ui: RebornUI = %RebornUI
@onready var heart_overlay: ColorRect = %HeartOverlay
@onready var crack_overlay: ColorRect = %CrackOverlay
@onready var switch_to_prestige_simple_tween: SimpleTween = %SwitchToPrestigeSimpleTween
@onready var switch_from_prestige_simple_tween: SimpleTween = %SwitchFromPrestigeSimpleTween
@onready var prestige_transition_simple_tween: SimpleTween = %PrestigeTransitionSimpleTween
@onready var reborn_transition_simple_tween: SimpleTween = %RebornTransitionSimpleTween
@onready var enter_simple_tween: SimpleTween = %EnterSimpleTween
@onready var enter_soul_simple_tween: SimpleTween = %EnterSoulSimpleTween
@onready var footer_h_box_container: HBoxContainer = %FooterHBoxContainer
@onready var event_tracker: MarginContainer = %EventTracker
@onready var resource_tracker: ResourceTracker = %ResourceTracker
@onready var body_margin_container: MarginContainer = %BodyMarginContainer
@onready var cat_sprite_2d: Sprite2D = %CatSprite2D
@onready var world_screen: WorldScreen = %WorldScreen
@onready var soul_sprite: SoulSprite = %SoulSprite

###############
## overrides ##
###############


func _ready() -> void:
	_connect_signals()
	_initialize()

	if Game.PARAMS["debug_logs"]:
		print("_READY: " + self.get_name())

	enter_simple_tween.play_animation()


#############
## helpers ##
#############


func _initialize() -> void:
	_reset_prestige_ui()

	tab_tracker.change_tab(0)

	var display_mode: String = SaveFile.settings["display_mode"]
	if display_mode == "fullscreen":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	cat_sprite_2d.visible = false
	soul_sprite.visible = false


func _reset_prestige_ui() -> void:
	main_ui.visible = true
	prestige_ui.reset_prestige_ui()
	reborn_ui.visible = false
	crack_overlay.visible = false


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.tab_changed.connect(_on_tab_changed)
	SignalBus.set_ui_theme.connect(_on_set_ui_theme)
	self.ready.connect(_on_ready)
	SignalBus.heart_click.connect(_on_heart_click)
	switch_to_prestige_simple_tween.animation_end.connect(_on_switch_to_prestige_simple_tween_end)
	switch_from_prestige_simple_tween.animation_end.connect(
		_on_switch_from_prestige_simple_tween_end
	)
	SignalBus.prestige_cancel.connect(_on_prestige_cancel)
	SignalBus.prestige_condition_pass.connect(_on_prestige_condition_pass)
	prestige_transition_simple_tween.animation_end.connect(_on_prestige_transition_end)
	SignalBus.prestige_reborn.connect(_on_prestige_reborn)
	reborn_transition_simple_tween.animation_end.connect(_on_reborn_transition_end)
	SignalBus.soul.connect(_on_soul)
	SignalBus.npc_event_interacted.connect(_on_npc_event_interacted)
	enter_soul_simple_tween.animation_end.connect(_on_enter_soul_simple_tween_end)


func _on_tab_changed(tab_data: TabData) -> void:
	if tab_data.id == StarwayScreen.TAB_DATA_ID:
		prestige_ui.visible = true
		if Game.PARAMS["heart_screen_shader"]:
			heart_overlay.visible = true
	else:
		prestige_ui.visible = false
		heart_overlay.visible = false


func _on_set_ui_theme(theme: Resource) -> void:
	main_control.theme = theme


func _on_ready() -> void:
	SignalBus.main_ready.emit()


func _on_heart_click() -> void:
	switch_to_prestige_simple_tween.play_animation()


func _on_switch_to_prestige_simple_tween_end() -> void:
	main_ui.visible = false
	prestige_ui.heart_content.visible = true


func _on_switch_from_prestige_simple_tween_end() -> void:
	pass


func _on_prestige_cancel() -> void:
	_reset_prestige_ui()
	prestige_ui.visible = true
	if Game.PARAMS["heart_screen_shader"]:
		heart_overlay.visible = true
	switch_from_prestige_simple_tween.play_animation()


func _on_prestige_condition_pass(infinity_count: int) -> void:
	_infinity_count = infinity_count
	main_ui.visible = false
	prestige_ui.visible = false
	reborn_ui.visible = true
	prestige_transition_simple_tween.play_animation()


func _on_prestige_transition_end() -> void:
	if Game.PARAMS["reborn_overlay_shader"]:
		crack_overlay.visible = true
	reborn_ui.push_next_label()


func _on_prestige_reborn() -> void:
	reborn_transition_simple_tween.play_animation()


func _on_reborn_transition_end() -> void:
	SaveFile.prestige(_infinity_count)
	Scene.change_scene("main_scene")


func _on_soul() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	soul_sprite.position = main_control.get_global_mouse_position()
	soul_sprite.visible = true


func _on_npc_event_interacted(npc_id: String, npc_event_id: String, _option: int) -> void:
	if npc_id == "cat" and npc_event_id == "cat_soul_crafted_1":
		cat_sprite_2d.visible = true
		var target: TextureRect = world_screen.npc_dialog.npc_texture_rect
		cat_sprite_2d.position = target.get_screen_position()
		cat_sprite_2d.position.x += target.get_rect().size.x / 2
		cat_sprite_2d.position.y += target.get_rect().size.y / 2
		SaveFile.cat_sprite_2d_position = cat_sprite_2d.position

		enter_soul_simple_tween.play_animation()


############
## export ##
############


func _switch_to_prestige(animation_percent: float) -> void:
	main_ui.modulate.a = 1.0 - animation_percent
	prestige_ui.heart_color_rect.modulate.a = animation_percent


func _switch_from_prestige(animation_percent: float) -> void:
	main_ui.modulate.a = animation_percent
	prestige_ui.heart_color_rect.modulate.a = 1.0 - animation_percent


func _prestige_transition(animation_percent: float) -> void:
	prestige_ui.modulate.a = 1.0 - animation_percent


func _reborn_transition(animation_percent: float) -> void:
	reborn_ui.modulate.a = 0
	if animation_percent > 0.5:
		crack_overlay.visible = false


func _enter_simple_tween(animation_percent: float) -> void:
	main_control.modulate.a = animation_percent


func _enter_soul_simple_tween(animation_percent: float) -> void:
	var alpha: float = 1.0 - animation_percent
	tab_tracker.modulate.a = alpha
	footer_h_box_container.modulate.a = alpha
	event_tracker.modulate.a = alpha
	resource_tracker.modulate.a = alpha
	body_margin_container.modulate.a = alpha


func _on_enter_soul_simple_tween_end() -> void:
	Scene.change_scene("soul_scene")
