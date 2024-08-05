class_name ManagerModeContainer
extends MarginContainer

@onready var normal_mode_button: Button = %NormalModeButton
@onready var smart_mode_button: Button = %SmartModeButton

###############
## overrides ##
###############


func _ready() -> void:
	_initialize()
	_load_from_save_file()
	_connect_signals()


#############
## helpers ##
#############


func _initialize() -> void:
	normal_mode_button.text = Locale.get_ui_label("normal_mode_button")
	smart_mode_button.text = Locale.get_ui_label("smart_mode_button")


func _load_from_save_file() -> void:
	var unlocked: bool = SaveFile.events.get("house_kingdom", 0) > 0  ## TODO move to susbtance?
	self.visible = unlocked

	var mode: int = SaveFile.settings.get("manager_mode", 0)
	_toggle_mode(mode)


func _toggle_mode(mode: int) -> void:
	if mode == 0:
		normal_mode_button.disabled = true
		smart_mode_button.disabled = false
	elif mode == 1:
		smart_mode_button.disabled = true
		normal_mode_button.disabled = false


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.event_saved.connect(_on_event_saved)
	normal_mode_button.mouse_entered.connect(_on_normal_mode_button_hover)
	smart_mode_button.mouse_entered.connect(_on_smart_mode_button_hover)
	normal_mode_button.button_down.connect(_on_normal_mode_button_down)
	smart_mode_button.button_down.connect(_on_smart_mode_button_down)
	normal_mode_button.button_up.connect(_on_normal_mode_button_up)
	smart_mode_button.button_up.connect(_on_smart_mode_button_up)


func _on_event_saved(event_data: EventData, _vals: Array, _index: int) -> void:
	if event_data.id == "house_kingdom":
		self.visible = true


func _on_normal_mode_button_hover() -> void:
	SignalBus.info_hover.emit(
		Locale.get_ui_label("normal_mode_button"), Locale.get_ui_label("normal_mode_button_info")
	)


func _on_smart_mode_button_hover() -> void:
	SignalBus.info_hover.emit(
		Locale.get_ui_label("smart_mode_button"), Locale.get_ui_label("smart_mode_button_info")
	)


func _on_normal_mode_button_down() -> void:
	normal_mode_button.release_focus()


func _on_smart_mode_button_down() -> void:
	smart_mode_button.release_focus()


func _on_normal_mode_button_up() -> void:
	_on_normal_mode_button_hover()
	_toggle_mode(0)
	SignalBus.toggle_manager_mode_pressed.emit(0)
	Audio.play_sfx_id("generic_click")


func _on_smart_mode_button_up() -> void:
	_on_smart_mode_button_hover()
	_toggle_mode(1)
	SignalBus.toggle_manager_mode_pressed.emit(1)
	Audio.play_sfx_id("generic_click")
