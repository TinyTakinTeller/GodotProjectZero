class_name ManagerModeContainer
extends MarginContainer

@onready var normal_mode_button: Button = %NormalModeButton
@onready var smart_mode_button: Button = %SmartModeButton
@onready var auto_mode_button: Button = %AutoModeButton

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
	auto_mode_button.text = Locale.get_ui_label("auto_mode_button")


func _load_from_save_file() -> void:
	var has_emperor: bool = SaveFile.substances.get("the_emperor", 0) > 0
	smart_mode_button.visible = has_emperor

	var has_the_hierophant: bool = SaveFile.substances.get("the_hierophant", 0) > 0
	auto_mode_button.visible = has_the_hierophant

	self.visible = smart_mode_button.visible or auto_mode_button.visible

	var mode: int = SaveFile.settings.get("manager_mode", 0)
	_toggle_mode(mode)


func _toggle_mode(mode: int) -> void:
	if mode == 0:
		normal_mode_button.disabled = true
		smart_mode_button.disabled = false
		auto_mode_button.disabled = false
	elif mode == 1:
		smart_mode_button.disabled = true
		normal_mode_button.disabled = false
		auto_mode_button.disabled = false
	elif mode == 2:
		auto_mode_button.disabled = true
		normal_mode_button.disabled = false
		smart_mode_button.disabled = false


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.substance_updated.connect(_on_substance_updated)
	normal_mode_button.mouse_entered.connect(_on_normal_mode_button_hover)
	smart_mode_button.mouse_entered.connect(_on_smart_mode_button_hover)
	auto_mode_button.mouse_entered.connect(_on_auto_mode_button_hover)

	normal_mode_button.button_down.connect(_on_normal_mode_button_down)
	smart_mode_button.button_down.connect(_on_smart_mode_button_down)
	auto_mode_button.button_down.connect(_on_auto_mode_button_down)

	normal_mode_button.button_up.connect(_on_normal_mode_button_up)
	smart_mode_button.button_up.connect(_on_smart_mode_button_up)
	auto_mode_button.button_up.connect(_on_auto_mode_button_up)


func _on_substance_updated(id: String, total_amount: int, _source_id: String) -> void:
	if (id == "the_emperor" or id == "the_hierophant") and total_amount > 0:
		_load_from_save_file()


func _on_normal_mode_button_hover() -> void:
	SignalBus.info_hover.emit(
		Locale.get_ui_label("normal_mode_button"), Locale.get_ui_label("normal_mode_button_info")
	)


func _on_smart_mode_button_hover() -> void:
	SignalBus.info_hover.emit(
		Locale.get_ui_label("smart_mode_button"), Locale.get_ui_label("smart_mode_button_info")
	)


func _on_auto_mode_button_hover() -> void:
	SignalBus.info_hover.emit(
		Locale.get_ui_label("auto_mode_button"), Locale.get_ui_label("auto_mode_button_info")
	)


func _on_normal_mode_button_down() -> void:
	normal_mode_button.release_focus()


func _on_smart_mode_button_down() -> void:
	smart_mode_button.release_focus()


func _on_auto_mode_button_down() -> void:
	auto_mode_button.release_focus()


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


func _on_auto_mode_button_up() -> void:
	_on_smart_mode_button_hover()
	_toggle_mode(2)
	SignalBus.toggle_manager_mode_pressed.emit(2)
	Audio.play_sfx_id("generic_click")
