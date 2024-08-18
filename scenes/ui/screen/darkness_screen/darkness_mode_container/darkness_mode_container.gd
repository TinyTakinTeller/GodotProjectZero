class_name DarknessModeContainer
extends MarginContainer

@onready var execute_button: Button = $HBoxContainer/ExeMarginContainer/ExecuteButton
@onready var manual_button: Button = $HBoxContainer/ManMarginContainer/ManualButton
@onready var absolve_button: Button = $HBoxContainer/AbsMarginContainer/AbsolveButton


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
	execute_button.text = Locale.get_ui_label("execute_mode_button")
	manual_button.text = Locale.get_ui_label("manual_mode_button")
	absolve_button.text = Locale.get_ui_label("absolve_mode_button")

func _load_from_save_file() -> void:
	var has_judgement: bool = SaveFile.substances.get("judgement", 0) > 0
	self.visible = has_judgement

	var mode: int = SaveFile.settings.get("darkness_mode", 0)
	_toggle_mode(mode)


func _toggle_mode(mode: int) -> void:
	if mode == 0:
		manual_button.disabled = true
		execute_button.disabled = false
		absolve_button.disabled = false
	elif mode == 1:
		execute_button.disabled = true
		manual_button.disabled = false
		absolve_button.disabled = false
	elif mode == 2:
		absolve_button.disabled = true
		manual_button.disabled = false
		execute_button.disabled = false


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.substance_updated.connect(_on_substance_updated)
	manual_button.mouse_entered.connect(_on_manual_button_hover)
	execute_button.mouse_entered.connect(_on_execute_button_hover)
	absolve_button.mouse_entered.connect(_on_absolve_button_hover)

	manual_button.button_down.connect(_on_manual_button_down)
	execute_button.button_down.connect(_on_execute_button_down)
	absolve_button.button_down.connect(_on_absolve_button_down)

	manual_button.button_up.connect(_on_manual_button_up)
	execute_button.button_up.connect(_on_execute_button_up)
	absolve_button.button_up.connect(_on_absolve_button_up)


func _on_substance_updated(id: String, total_amount: int, _source_id: String) -> void:
	if id == "judgement" and total_amount > 0:
		_load_from_save_file()


func _on_manual_button_hover() -> void:
	SignalBus.info_hover.emit(
		Locale.get_ui_label("manual_button"), Locale.get_ui_label("manual_button_info")
	)


func _on_execute_button_hover() -> void:
	SignalBus.info_hover.emit(
		Locale.get_ui_label("execute_button"), Locale.get_ui_label("execute_button_info")
	)


func _on_absolve_button_hover() -> void:
	SignalBus.info_hover.emit(
		Locale.get_ui_label("absolve_button"), Locale.get_ui_label("absolve_button_info")
	)


func _on_manual_button_down() -> void:
	manual_button.release_focus()


func _on_execute_button_down() -> void:
	execute_button.release_focus()


func _on_absolve_button_down() -> void:
	absolve_button.release_focus()


func _on_manual_button_up() -> void:
	_on_manual_button_hover()
	_toggle_mode(0)
	SignalBus.toggle_darkness_mode_pressed.emit(0)
	Audio.play_sfx_id("generic_click")


func _on_execute_button_up() -> void:
	_on_execute_button_hover()
	_toggle_mode(1)
	SignalBus.toggle_darkness_mode_pressed.emit(1)
	Audio.play_sfx_id("generic_click")


func _on_absolve_button_up() -> void:
	_on_execute_button_hover()
	_toggle_mode(2)
	SignalBus.toggle_darkness_mode_pressed.emit(2)
	Audio.play_sfx_id("generic_click")
