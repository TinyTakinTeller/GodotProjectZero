class_name SubstanceItem extends MarginContainer

var _substance_data: SubstanceData

@onready var icon_margin_container: MarginContainer = %IconMarginContainer
@onready var texture_margin_container: MarginContainer = %TextureMarginContainer
@onready var label_margin_container: MarginContainer = %LabelMarginContainer
@onready var count_margin_container: MarginContainer = %CountMarginContainer
@onready var craft_button_margin_container: MarginContainer = %CraftButtonMarginContainer
@onready var texture_rect: TextureRect = %TextureRect
@onready var texture_button: Button = %TextureButton
@onready var count_label: Label = %CountLabel
@onready var craft_button: Button = %CraftButton
@onready var panel: Panel = %Panel
@onready var panel_highlight: Panel = %PanelHighlight
@onready var new_unlock_tween: NewUnlockTween = %NewUnlockTween
@onready var red_color_rect_simple_tween: SimpleTween = %RedColorRectSimpleTween
@onready var red_color_rect: ColorRect = %RedColorRect
@onready var shake_shader_component: ShakeShaderComponent = %ShakeShaderComponent
@onready var craft_label: Label = %CraftLabel

###############
## overrides ##
###############


func _ready() -> void:
	_connect_signals()
	_initialize()


###########
## setup ##
###########


func get_id() -> String:
	if _substance_data == null:
		return ""
	return _substance_data.get_id()


func set_data(substance_data: SubstanceData) -> void:
	_substance_data = substance_data


func display_data() -> void:
	refresh_image()
	refresh_count()
	refresh_color()
	_update_pivot()


func refresh_image() -> void:
	if _substance_data == null:
		return
	texture_rect.texture = _substance_data.get_image_texture()


func refresh_count() -> void:
	refresh_craft_button()

	var count: int = SaveFile.substances.get(get_id(), 0)  # + 1

	var is_unlocked: bool = _substance_data.is_unlocked()
	var is_charm: bool = _substance_data.get_category_id() == "charm" and is_unlocked
	if is_charm:
		self.visible = true

	if count > 0:
		texture_margin_container.visible = true
		label_margin_container.visible = false
		self.visible = true

		if is_charm:
			craft_button.visible = false
	else:
		texture_margin_container.visible = false
		label_margin_container.visible = true

		var is_hidden: bool = _substance_data.is_hidden() and not is_charm
		if is_hidden:
			self.visible = false
		panel.visible = true

	if count > 1:
		count_label.text = "x" + NumberUtils.format_number(count)
		count_margin_container.visible = true
	else:
		count_label.text = ""
		count_margin_container.visible = false


func refresh_craft_button() -> void:
	if _substance_data.is_craftable():
		craft_button.disabled = false
		craft_button_margin_container.visible = true
	else:
		craft_button.disabled = true
		craft_button_margin_container.visible = false

	craft_label.text = _substance_data.get_craft_icon()


func refresh_color() -> void:
	if _substance_data.is_color():
		self.modulate = _substance_data.get_color()


func play_unlock_animation() -> void:
	panel.visible = true
	new_unlock_tween.play_animation()


func stop_unlock_animation() -> void:
	panel.visible = false
	new_unlock_tween.loop = false


#############
## helpers ##
#############


func _initialize() -> void:
	_set_ui_labels()


func _set_ui_labels() -> void:
	craft_button.text = Locale.get_ui_label("craft")


func _update_pivot() -> void:
	icon_margin_container.set_pivot_offset(
		Vector2(icon_margin_container.size.x / 2, icon_margin_container.size.y / 2)
	)


#############
## signals ##
#############


func _connect_signals() -> void:
	texture_button.mouse_exited.connect(_on_texture_button_unhover)
	texture_button.mouse_entered.connect(_on_texture_button_hover)
	craft_button.mouse_entered.connect(_on_craft_button_hover)
	texture_button.button_down.connect(_on_texture_button_down)
	craft_button.button_down.connect(_on_craft_button_down)
	craft_button.button_up.connect(_on_craft_button_up)
	SignalBus.event_saved.connect(_on_event_saved)
	SignalBus.substance_updated.connect(_on_substance_updated)
	SignalBus.substance_craft_button_unpaid.connect(_on_substance_craft_button_unpaid)


func _on_texture_button_unhover() -> void:
	pass  # panel.visible = false


func _on_texture_button_hover() -> void:
	if _substance_data == null:
		return

	SignalBus.info_hover.emit(
		_substance_data.get_display_title(), _substance_data.get_display_info()
	)

	# panel.visible = true
	stop_unlock_animation()


func _on_craft_button_hover() -> void:
	if _substance_data == null:
		return

	SignalBus.info_hover.emit(_substance_data.get_craft_title(), _substance_data.get_craft_info())


func _on_texture_button_down() -> void:
	_on_texture_button_hover()
	texture_button.release_focus()


func _on_craft_button_down() -> void:
	_on_craft_button_hover()


func _on_craft_button_up() -> void:
	craft_button.release_focus()
	if _substance_data != null:
		SignalBus.substance_craft_button_pressed.emit(_substance_data)


func _on_event_saved(event_data: EventData, _vals: Array, _index: int) -> void:
	if (
		_substance_data != null
		and _substance_data.get_category_id() == "charm"
		and event_data.id == "darkness_10"
	):
		refresh_count()

		#play_unlock_animation()


func _on_substance_updated(_id: String, _total_amount: int, _source_id: String) -> void:
	if _substance_data != null:
		refresh_count()

		#if _substance_data.unlocked_by == id and total_amount == 1:
		#	play_unlock_animation()


func _on_substance_craft_button_unpaid(substance_data: SubstanceData) -> void:
	if get_id() == substance_data.get_id():
		red_color_rect_simple_tween.play_animation()

		Audio.play_sfx_id("progress_button_fail")


############
## export ##
############


func _red_color_rect_simple_tween_method(animation_percent: float) -> void:
	red_color_rect.modulate.a = 1 - animation_percent


############
## static ##
############


static func before_than(a: SubstanceItem, b: SubstanceItem) -> bool:
	var sort_a: SubstanceData = Resources.substance_datas.get(a.get_id(), null)
	var sort_b: SubstanceData = Resources.substance_datas.get(b.get_id(), null)
	if sort_a == null:
		return true
	if sort_b == null:
		return false

	return sort_a.get_sort_value() < sort_b.get_sort_value()
