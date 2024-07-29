class_name PrestigeUI extends Control

@onready var heart_color_rect: ColorRect = %HeartColorRect
@onready var heart_content: MarginContainer = %HeartContent
@onready var heart_buttons: HBoxContainer = %HeartButtons
@onready var heart_yes_button: Button = %HeartYesButton
@onready var heart_no_button: Button = %HeartNoButton
@onready var heart_info: MarginContainer = %HeartInfo
@onready var dialog_heart_button: Button = %DialogHeartButton
@onready var dialog_heart_buttons: MarginContainer = %DialogHeartButtons
@onready var label_prestige_info_left: Label = %LabelPrestigeInfoLeft
@onready var label_prestige_info_right: Label = %LabelPrestigeInfoRight
@onready var comming_soon_info: MarginContainer = %CommingSoonInfo

###############
## overrides ##
###############


func _ready() -> void:
	_connect_signals()
	_initialize()

	if Game.PARAMS["debug_logs"]:
		print("_READY: " + self.get_name())


#############
## methods ##
#############


func reset_prestige_ui() -> void:
	self.visible = false
	heart_color_rect.modulate.a = 0.0
	heart_content.visible = false
	dialog_heart_buttons.visible = true
	heart_info.visible = false
	heart_buttons.visible = false

	heart_yes_button.disabled = false
	comming_soon_info.visible = false


#############
## helpers ##
#############


func _initialize() -> void:
	dialog_heart_button.text = Locale.get_ui_label("heart_dialog")
	heart_yes_button.text = Locale.get_ui_label("heart_yes")
	heart_no_button.text = Locale.get_ui_label("heart_no")
	label_prestige_info_left.text = Locale.get_ui_label("heart_prestige_info_1")
	label_prestige_info_right.text = Locale.get_ui_label("heart_prestige_info_2")


#############
## signals ##
#############


func _connect_signals() -> void:
	dialog_heart_button.button_up.connect(_on_dialog_heart_button)
	heart_no_button.button_up.connect(_on_heart_no_button)
	heart_yes_button.button_up.connect(_on_heart_yes_button)


func _on_dialog_heart_button() -> void:
	dialog_heart_buttons.visible = false
	heart_info.visible = true
	heart_buttons.visible = true

	Audio.play_sfx_id("generic_click")


func _on_heart_no_button() -> void:
	SignalBus.prestige_cancel.emit()


func _on_heart_yes_button() -> void:
	heart_yes_button.disabled = true
	comming_soon_info.visible = true
