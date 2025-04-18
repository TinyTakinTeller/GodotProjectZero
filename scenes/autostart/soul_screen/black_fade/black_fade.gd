class_name TerminatedOverlay
extends MarginContainer

signal terminated

@onready var color_rect: ColorRect = %ColorRect
@onready var fade_in_tween: SimpleTween = %FadeInTween
@onready var label: Label = %Label
@onready var button: Button = %Button

###############
## overrides ##
###############


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("escape_game"):
		if get_tree().paused:
			get_tree().paused = false
			Scene.change_scene("save_file_picker_scene")


func _ready() -> void:
	_connect_signals()
	_initialize()


#############
## helpers ##
#############


func _initialize() -> void:
	self.visible = false
	label.visible = false
	button.visible = false
	label.text = Locale.get_ui_label("game_over_text")


###############
## animation ##
###############


func _fade_in() -> void:
	fade_in_tween.play_animation()


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.player_death.connect(_on_player_death)
	fade_in_tween.animation_end.connect(_on_fade_in_end)
	button.button_up.connect(_on_button_up)


func _on_player_death() -> void:
	self.modulate.a = 0.0
	self.visible = true
	_fade_in()


func _on_fade_in_end() -> void:
	label.visible = true
	button.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_button_up() -> void:
	terminated.emit()
	button.disabled = true


#############
## exports ##
#############


func _fade_in_tween(percent: float) -> void:
	self.modulate.a = percent
