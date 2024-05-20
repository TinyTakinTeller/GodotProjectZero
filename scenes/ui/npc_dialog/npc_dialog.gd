extends MarginContainer
class_name NpcDialog

@onready var dialog_label: Label = %DialogLabel
@onready var yes_button: Button = %YesButton
@onready var no_button: Button = %NoButton
@onready var npc_margin_container: MarginContainer = %NpcMarginContainer
@onready var npc_texture_rect: TextureRect = %NpcTextureRect
@onready var typing_text_tween: Node = %TypingTextTween
@onready var enter_simple_tween: SimpleTween = %EnterSimpleTween

@export var _npc_id: String

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


func peek(alpha: float, hide_ui: bool = true) -> void:
	if hide_ui:
		_hide_ui()
	npc_texture_rect.modulate.a = alpha


func play_enter_animation() -> void:
	enter_simple_tween.play_animation()


func play_typing_animation(on_load: bool = false) -> void:
	if !is_event_active():
		peek(0.1)
		return

	if npc_texture_rect.modulate.a != 1.0 and !on_load:
		play_enter_animation()
		return

	dialog_label.text = _next_text
	if !on_load:
		yes_button.disabled = true
		no_button.disabled = true
		var duration: float = dialog_label.text.length() * Game.params["animation_speed_diary"]
		typing_text_tween.play_animation(duration)
	else:
		peek(1, false)
		_show_and_enable_buttons()


#############
## helpers ##
#############


func _initialize() -> void:
	if _npc_id == null:
		peek(0)
		return
	_load_next_active_event()


func _clear_active_event() -> void:
	_next_text = ""
	_target_id = ""


func _load_next_active_event() -> void:
	_clear_active_event()

	var npc_events: Dictionary = SaveFile.npc_events.get(_npc_id, {})
	if npc_events.size() == 0:
		peek(0)
		return
	peek(0.1)

	for npc_event_id: String in npc_events:
		var npc_event_value: int = npc_events[npc_event_id]
		if npc_event_value == 0:
			var npc_event: NpcEvent = Resources.npc_events[npc_event_id]
			if npc_event.is_a_question():
				_next_text = npc_event.get_text()
				_target_id = npc_event_id
				play_typing_animation(true)
				return


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
	no_button.visible = true
	yes_button.disabled = false
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


func _on_typing_text_tween_animation_end() -> void:
	_show_and_enable_buttons()


func _on_enter_simple_tween_animation_end() -> void:
	npc_texture_rect.modulate.a = 1.0
	npc_margin_container.add_theme_constant_override("margin_bottom", 20)
	play_typing_animation()


func _on_yes_button_down() -> void:
	_hide_ui()
	SignalBus.npc_event_interacted.emit(_npc_id, _target_id, 1)
	_load_next_active_event()


func _on_no_button_down() -> void:
	_hide_ui()
	SignalBus.npc_event_interacted.emit(_npc_id, _target_id, 2)
	_load_next_active_event()


func _on_npc_event_saved(npc_event: NpcEvent) -> void:
	if _npc_id != npc_event.get_npc_id():
		return
	if !is_event_active():
		_next_text = npc_event.get_text()
		_target_id = npc_event.get_id()
		play_typing_animation()


############
## export ##
############


func __enter_simple_tween_method(animation_percent: float) -> void:
	if int(animation_percent * 16) % 2 == 0:
		npc_texture_rect.modulate.a = 0.2 + animation_percent * 0.8
		npc_margin_container.add_theme_constant_override("margin_bottom", 20)
	else:
		npc_margin_container.add_theme_constant_override("margin_bottom", 25)
