class_name SubstanceButton extends MarginContainer

var _enemy_data: EnemyData
var _enemy_option: int

@onready var texture_margin_container: MarginContainer = %TextureMarginContainer
@onready var texture_rect: TextureRect = %TextureRect
@onready var title_label: Label = %TitleLabel
@onready var button: Button = %Button
@onready var effect_label: Label = %EffectLabel

###############
## overrides ##
###############


func _ready() -> void:
	_initialize()
	_connect_signals()


###########
## setup ##
###########


func get_id() -> String:
	if _enemy_data == null:
		return ""
	return _enemy_data.id


func get_title() -> String:
	return _enemy_data.get_enemy_data_option_title(_enemy_option)


func get_color() -> Color:
	if _enemy_option == 2:
		return ColorSwatches.GREEN
	if _enemy_option == 1:
		return ColorSwatches.RED
	return Color.WHITE


func set_data(enemy_data: EnemyData) -> void:
	_enemy_data = enemy_data
	_enemy_option = SaveFile.get_enemy_option(enemy_data.id)


func display_data() -> void:
	texture_rect.texture = _enemy_data.get_enemy_icon_texture()
	title_label.text = get_title()
	texture_margin_container.modulate = get_color()
	texture_margin_container.modulate.a = 0.5
	effect_label.modulate = get_color()
	effect_label.text = Locale.get_enemy_data_option_title("null", _enemy_option)


#############
## helpers ##
#############


func _initialize() -> void:
	_set_ui_labels()


func _set_ui_labels() -> void:
	var ui_upgrade: String = Locale.get_ui_label("upgrade")
	button.text = ui_upgrade


#############
## signals ##
#############


func _connect_signals() -> void:
	button.button_down.connect(_on_button_down)
	self.mouse_entered.connect(_on_mouse_entered)


func _on_button_down() -> void:
	button.release_focus()


func _on_mouse_entered() -> void:
	pass  # SignalBus.info_hover.emit(get_title(), _enemy_data.get_info())


############
## static ##
############


static func before_than(a: SubstanceButton, b: SubstanceButton) -> bool:
	var sort_a: EnemyData = Resources.enemy_datas.get(a.get_id(), null)
	var sort_b: EnemyData = Resources.enemy_datas.get(b.get_id(), null)
	if sort_a == null:
		return true
	if sort_b == null:
		return false

	return sort_a.get_sort_value() < sort_b.get_sort_value()
