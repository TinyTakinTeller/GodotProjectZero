extends MarginContainer
class_name TabTrackerItem

signal click(tab_data: TabData)

@onready var button: Button = %Button
@onready var new_unlock_tween: Node = %NewUnlockTween

var _tab_data: TabData

###############
## overrides ##
###############


func _ready() -> void:
	_connect_signals()


###########
## setup ##
###########


func get_tab_data() -> TabData:
	return _tab_data


func set_tab_data(tab_data: TabData) -> void:
	_tab_data = tab_data
	refresh_title()


func refresh_title() -> void:
	button.text = _tab_data.get_title()


###############
## animation ##
###############


func start_unlock_animation() -> void:
	new_unlock_tween.loop = true
	new_unlock_tween.play_animation()


func stop_unlock_animation() -> void:
	new_unlock_tween.loop = false


#############
## helpers ##
#############


func _update_pivot() -> void:
	self.set_pivot_offset(Vector2(self.size.x / 2, self.size.y / 2))


##############
## handlers ##
##############


func _handle_on_button_up() -> void:
	stop_unlock_animation()
	button.disabled = true
	click.emit(_tab_data)
	button.release_focus()


#############
## signals ##
#############


func _connect_signals() -> void:
	self.resized.connect(_on_resized)
	button.button_down.connect(_on_button_down)
	button.button_up.connect(_on_button_up)
	button.mouse_entered.connect(_on_mouse_entered)


func _on_resized() -> void:
	_update_pivot()


func _on_button_down() -> void:
	button.release_focus()


func _on_button_up() -> void:
	_handle_on_button_up()


func _on_mouse_entered() -> void:
	pass
