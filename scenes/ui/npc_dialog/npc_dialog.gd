extends MarginContainer
class_name NpcDialog

const PEEK_ALPHA: Array[float] = [0, 0.1, 1.0]

@onready var dialog_label: Label = %DialogLabel
@onready var yes_button: Button = %YesButton
@onready var no_button: Button = %NoButton
@onready var npc_margin_container: MarginContainer = %NpcMarginContainer
@onready var npc_texture_rect: TextureRect = %NpcTextureRect
@onready var npc_button: Button = %NpcButton
@onready var typing_text_tween: Node = %TypingTextTween
@onready var enter_simple_tween: SimpleTween = %EnterSimpleTween

@export var _npc_id: String

var _peek_state: int = 0
var _next_text: String = ""
var _target_id: String = ""

###############
## overrides ##
###############


func _ready() -> void:
	_initialize()
	_connect_signals()


###############
## animation ##
###############


func is_event_active() -> bool:
	return _target_id.length() != 0 and _next_text.length() != 0


func peek(peek_state: int) -> void:
	_peek_state = peek_state
	npc_texture_rect.modulate.a = PEEK_ALPHA[peek_state]

	if peek_state == 0:
		visible = false
	else:
		visible = true


func play_typing_animation(on_load: bool = false) -> void:
	if !is_event_active():
		peek(1)
		_hide_ui()
		return

	if _peek_state != 2 and !on_load:
		enter_simple_tween.play_animation()
		return

	dialog_label.text = _next_text
	if !on_load:
		yes_button.disabled = true
		no_button.disabled = true
		var duration: float = dialog_label.text.length() * Game.params["animation_speed_diary"]
		typing_text_tween.play_animation(duration)
	else:
		peek(2)
		_show_and_enable_buttons()


#############
## helpers ##
#############


func _initialize() -> void:
	_hide_ui()
	if _npc_id == null:
		peek(0)
		return
	_load_next_active_event(true)


func _clear_active_event() -> void:
	_next_text = ""
	_target_id = ""


func _load_next_active_event(on_load: bool = false) -> void:
	_clear_active_event()

	var npc_events: Dictionary = SaveFile.npc_events.get(_npc_id, {})
	if npc_events.size() == 0:
		peek(0)
		_hide_ui()
		return

	for npc_event_id: String in npc_events:
		var npc_event_value: int = npc_events[npc_event_id]
		if npc_event_value == -1:
			var npc_event: NpcEvent = Resources.npc_events[npc_event_id]
			if npc_event.is_interactable():
				yes_button.text = npc_event.options[0]
				if npc_event.options.size() > 1:
					no_button.text = npc_event.options[1]
				else:
					no_button.text = ""
				_next_text = npc_event.get_text()
				_target_id = npc_event_id
				play_typing_animation(on_load)
				return
	peek(1)
	_hide_ui()


func _hide_ui() -> void:
	dialog_label.text = ""
	_hide_buttons()


func _disable_buttons() -> void:
	yes_button.disabled = true
	no_button.disabled = true


func _hide_buttons() -> void:
	yes_button.visible = false
	no_button.visible = false


func _show_and_enable_buttons() -> void:
	yes_button.visible = true
	yes_button.disabled = false
	if no_button.text.length() > 0:
		no_button.visible = true
		no_button.disabled = false


#############
## signals ##
#############


func _connect_signals() -> void:
	typing_text_tween.animation_end.connect(_on_typing_text_tween_animation_end)
	enter_simple_tween.animation_end.connect(_on_enter_simple_tween_animation_end)
	yes_button.button_down.connect(_on_yes_button_down)
	no_button.button_down.connect(_on_no_button_down)
	SignalBus.npc_event_saved.connect(_on_npc_event_saved)
	npc_button.mouse_entered.connect(_on_npc_hover)
	npc_button.mouse_exited.connect(_on_npc_hover_stop)
	npc_button.pressed.connect(_on_npc_button_pressed)


func _on_typing_text_tween_animation_end() -> void:
	_show_and_enable_buttons()


func _on_enter_simple_tween_animation_end() -> void:
	_peek_state = 2
	npc_texture_rect.modulate.a = 1.0
	npc_margin_container.add_theme_constant_override("margin_bottom", 20)
	play_typing_animation()


func _on_yes_button_down() -> void:
	_hide_ui()
	SignalBus.npc_event_interacted.emit(_npc_id, _target_id, 0)
	_load_next_active_event()


func _on_no_button_down() -> void:
	_hide_ui()
	SignalBus.npc_event_interacted.emit(_npc_id, _target_id, 1)
	_load_next_active_event()


func _on_npc_event_saved(npc_event: NpcEvent) -> void:
	if _npc_id != npc_event.get_npc_id():
		return
	if !is_event_active():
		_next_text = npc_event.get_text()
		_target_id = npc_event.get_id()
		play_typing_animation()


func _on_npc_hover() -> void:
	SignalBus.info_hover.emit(Info.get_npc_hover_title(_npc_id), Info.get_npc_hover_info(_npc_id))


func _on_npc_hover_stop() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_npc_button_pressed() -> void:
	SignalBus.info_hover_shader.emit(
		Info.get_npc_click_title(_npc_id), Info.get_npc_click_info(_npc_id)
	)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


############
## export ##
############


func __enter_simple_tween_method(animation_percent: float) -> void:
	if int(animation_percent * 16) % 2 == 0:
		npc_texture_rect.modulate.a = 0.2 + animation_percent * 0.8
		npc_margin_container.add_theme_constant_override("margin_bottom", 20)
	else:
		npc_margin_container.add_theme_constant_override("margin_bottom", 25)
