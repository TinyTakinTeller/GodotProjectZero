extends MarginContainer

@onready var color_rect: ColorRect = %ColorRect
@onready var fade_in_tween: SimpleTween = %FadeInTween
@onready var label: Label = %Label

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
	self.visible = false
	label.visible = false
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


func _on_player_death() -> void:
	self.modulate.a = 0.0
	self.visible = true
	_fade_in()


func _on_fade_in_end() -> void:
	label.visible = true


#############
## exports ##
#############


func _fade_in_tween(percent: float) -> void:
	self.modulate.a = percent
