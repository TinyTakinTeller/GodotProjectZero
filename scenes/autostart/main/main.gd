extends Node

@onready var main_control: Control = %MainControl
@onready var tab_tracker: TabTracker = %TabTracker
@onready var ui: Control = %UI
@onready var prestige_ui: PrestigeUI = %PrestigeUI
@onready var heart_overlay: ColorRect = %HeartOverlay
@onready var switch_to_prestige_simple_tween: SimpleTween = %SwitchToPrestigeSimpleTween
@onready var switch_from_prestige_simple_tween: SimpleTween = %SwitchFromPrestigeSimpleTween

###############
## overrides ##
###############


func _ready() -> void:
	_connect_signals()
	_initialize()

	if Game.PARAMS["debug_logs"]:
		print("_READY: " + self.get_name())


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


func _reset_prestige_ui() -> void:
	ui.visible = true
	prestige_ui.reset_prestige_ui()


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
	ui.visible = false
	prestige_ui.heart_content.visible = true


func _on_switch_from_prestige_simple_tween_end() -> void:
	pass


func _on_prestige_cancel() -> void:
	_reset_prestige_ui()
	prestige_ui.visible = true
	if Game.PARAMS["heart_screen_shader"]:
		heart_overlay.visible = true
	switch_from_prestige_simple_tween.play_animation()


############
## export ##
############


func _switch_to_prestige(animation_percent: float) -> void:
	ui.modulate.a = 1.0 - animation_percent
	prestige_ui.heart_color_rect.modulate.a = animation_percent


func _switch_from_prestige(animation_percent: float) -> void:
	ui.modulate.a = animation_percent
	prestige_ui.heart_color_rect.modulate.a = 1.0 - animation_percent
