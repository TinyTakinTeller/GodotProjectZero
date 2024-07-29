extends MarginContainer

var unknown_tab_data: TabData = Resources.tab_datas["unknown"]

var _clicked: bool = false

@onready var heart_texture: TextureRect = %HeartTexture
@onready var heart_button: Button = %HeartButton

###############
## overrides ##
###############


func _ready() -> void:
	_connect_signals()
	_initialize()


#############
## helpers ##
#############


func _initialize() -> void:
	_enter_normal_mode()


func _enter_normal_mode() -> void:
	heart_texture.material.set_shader_parameter("period", 4.161)
	heart_texture.material.set_shader_parameter("period2", 4.161)
	SignalBus.heart_unclick.emit()
	_clicked = false
	SaveFile.prestige_dialog = false


func _enter_fast_mode() -> void:
	heart_texture.material.set_shader_parameter("period", 8.322)
	heart_texture.material.set_shader_parameter("period2", 8.322)
	SignalBus.heart_click.emit()
	_clicked = true
	SaveFile.prestige_dialog = true


#############
## signals ##
#############


func _connect_signals() -> void:
	heart_button.mouse_entered.connect(_on_heart_hover)
	heart_button.button_down.connect(_on_heart_clicked)
	SignalBus.prestige_cancel.connect(_on_prestige_cancel)


func _on_heart_hover() -> void:
	SignalBus.info_hover_shader.emit(
		Locale.get_ui_label("heart_title"), Locale.get_ui_label("heart_info")
	)


func _on_heart_clicked() -> void:
	if _clicked:
		return
	_enter_fast_mode()

	Audio.play_sfx_id("cat_click", 0.5, 2.0)


func _on_prestige_cancel() -> void:
	_enter_normal_mode()
