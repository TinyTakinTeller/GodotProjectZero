extends MarginContainer

var targets: Array = []
var clicks: int = 0

@onready var button: Button = %Button

###############
## overrides ##
###############


func _ready() -> void:
	_initialize()
	_connect_signals()


#############
## helpers ##
#############


func _initialize() -> void:
	button.text = Locale.get_ui_label("soul_button")
	button.disabled = false
	button.release_focus()

	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var target_position: Vector2 = viewport_size / 2
	target_position.x -= self.get_rect().size.x / 2
	target_position.y += viewport_size.y / 2 - 72
	targets.append(target_position)

	target_position = viewport_size / 6
	targets.append(target_position)

	target_position = viewport_size / 6
	target_position.x = 4.5 * viewport_size.x / 6
	targets.append(target_position)

	self.position = targets[0]


###############
## animation ##
###############


func _slide_to_target(target_position: Vector2) -> void:
	var tween: Tween = create_tween()
	tween.finished.connect(_slide_to_target_animation_end)
	(
		tween
		. tween_property(self, "position", target_position, 1.0)
		. set_ease(Tween.EASE_IN_OUT)
		. set_trans(Tween.TRANS_CUBIC)
	)


#############
## signals ##
#############


func _connect_signals() -> void:
	button.button_down.connect(_on_button_down)
	SignalBus.boss_end.connect(_on_boss_end)


func _on_button_down() -> void:
	button.disabled = true
	clicks += 1
	_slide_to_target(targets[clicks % targets.size()])

	SignalBus.boss_click.emit()
	Audio.play_sfx_id("buh_hit_hurt")

	if clicks % targets.size() == 0:
		SignalBus.boss_cycle.emit()


func _on_boss_end() -> void:
	self.visible = false


func _slide_to_target_animation_end() -> void:
	button.disabled = false
	button.release_focus()
