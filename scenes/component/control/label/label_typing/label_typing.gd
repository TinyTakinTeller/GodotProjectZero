class_name LabelTyping extends Label

signal typing_animation_end

var _typing_delay: float
var _loop: bool = false
var _end_delay: float = 0.0

@onready var typing_text_tween: TypingTextTween = %TypingTextTween
@onready var end_delay_timer: Timer = %EndDelayTimer

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
	pass


func _load_from_save_file() -> void:
	var value: float = SaveFile.effect_settings["typing"]["value"]
	var toggle: float = SaveFile.effect_settings["typing"]["toggle"]
	update_typing_effect(toggle, value)


func _normalize_typing_effect(value: float) -> float:
	return value / 4.0


#############
## methods ##
#############


func set_end_delay(end_delay: float) -> void:
	_end_delay = end_delay
	end_delay_timer.wait_time = _end_delay
	if _end_delay != 0.0:
		typing_text_tween.set_loop(false)


func play_typing_animation(loop: bool = false) -> void:
	_loop = loop
	var animation_length: float = self.text.length() * _typing_delay
	typing_text_tween.play_animation(animation_length, _loop)


func update_typing_effect(toggle: bool, value: float) -> void:
	if toggle:
		_typing_delay = _normalize_typing_effect(value)
	else:
		_typing_delay = 0.0
		self.visible_ratio = 1.0

	if is_inside_tree():
		if _loop:
			play_typing_animation(true)


#############
## signals ##
#############


func _connect_signals() -> void:
	typing_text_tween.animation_end.connect(_on_typing_text_tween_animation_end)
	end_delay_timer.timeout.connect(_on_timeout)

	SignalBus.effect_settings_updated.connect(_on_effect_settings_updated)


func _on_typing_text_tween_animation_end() -> void:
	if _end_delay == 0.0:
		typing_animation_end.emit()
	else:
		end_delay_timer.start()


func _on_timeout() -> void:
	typing_animation_end.emit()
	play_typing_animation()


func _on_effect_settings_updated(toggle: bool, value: float, id: String) -> void:
	if id == "typing":
		update_typing_effect(toggle, value)
