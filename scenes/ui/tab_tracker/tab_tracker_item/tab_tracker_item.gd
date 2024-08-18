class_name TabTrackerItem extends MarginContainer

signal click(tab_data: TabData)

var _tab_data: TabData
var _tab_tracker: TabTracker

@onready var button: Button = %Button
@onready var new_unlock_tween: Node = %NewUnlockTween

###############
## overrides ##
###############


func _ready() -> void:
	_connect_signals()


###########
## setup ##
###########


func get_id() -> String:
	if _tab_data == null:
		return ""
	return _tab_data.id


func get_tab_data() -> TabData:
	return _tab_data


func set_tab_data(tab_data: TabData, tab_tracker: TabTracker) -> void:
	_tab_data = tab_data
	_tab_tracker = tab_tracker


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


func _is_selected() -> bool:
	if _tab_tracker != null and _tab_data != null:
		return _tab_tracker.tab_selected_id == get_id()
	return false


func _update_pivot() -> void:
	self.set_pivot_offset(Vector2(self.size.x / 2, self.size.y / 2))


##############
## handlers ##
##############


func _handle_on_button_up() -> void:
	#if get_id() != "enemy":
	stop_unlock_animation()

	button.disabled = true
	click.emit(_tab_data)
	button.release_focus()

	Audio.play_sfx_id("generic_click")


#############
## signals ##
#############


func _connect_signals() -> void:
	#SignalBus.deaths_door_decided.connect(_on_deaths_door_decided)
	self.resized.connect(_on_resized)
	button.button_down.connect(_on_button_down)
	button.button_up.connect(_on_button_up)
	button.mouse_entered.connect(_on_mouse_entered)
	SignalBus.progress_button_unlocked.connect(_on_progress_button_unlocked)
	SignalBus.manager_button_unlocked.connect(_on_manager_button_unlocked)
	SignalBus.deaths_door_open.connect(_on_deaths_door_open)
	SignalBus.deaths_door_resolved.connect(_on_deaths_door_resolved)
	SignalBus.substance_updated.connect(_on_substance_updated)
	SignalBus.event_saved.connect(_on_event_saved)


#func _on_deaths_door_decided(_enemy_data: EnemyData, _option: int) -> void:
#	if get_id() == "enemy":
#		stop_unlock_animation()


func _on_resized() -> void:
	_update_pivot()


func _on_button_down() -> void:
	button.release_focus()


func _on_button_up() -> void:
	_handle_on_button_up()


func _on_mouse_entered() -> void:
	SignalBus.info_hover_tab.emit(_tab_data)


func _on_progress_button_unlocked(_resource_generator: ResourceGenerator) -> void:
	if _tab_data != null and get_id() == "world" and !_is_selected():
		start_unlock_animation()


func _on_manager_button_unlocked(_worker_role: WorkerRole) -> void:
	if _tab_data != null and get_id() == "manager" and !_is_selected():
		start_unlock_animation()


func _on_deaths_door_open(enemy_data: EnemyData) -> void:
	if _tab_data != null and get_id() == "enemy" and !_is_selected() and !enemy_data.is_last():
		start_unlock_animation()


func _on_deaths_door_resolved(
	enemy_data: EnemyData, _new_enemy_data: EnemyData, _option: int
) -> void:
	if _tab_data != null and get_id() == "soul" and !enemy_data.is_last() and !_is_selected():
		start_unlock_animation()


func _on_substance_updated(_id: String, _total_amount: int, _source_id: String) -> void:
	if _tab_data != null and get_id() == "substance" and !_is_selected():
		start_unlock_animation()


func _on_event_saved(event_data: EventData, _vals: Array, _index: int) -> void:
	if _tab_data != null and get_id() == "substance" and event_data.id == "darkness_10":
		start_unlock_animation()


############
## static ##
############


static func before_than(a: TabTrackerItem, b: TabTrackerItem) -> bool:
	var sort_a: TabData = Resources.tab_datas.get(a.get_id(), null)
	var sort_b: TabData = Resources.tab_datas.get(b.get_id(), null)
	if sort_a == null:
		return true
	if sort_b == null:
		return false

	return sort_a.get_sort_value() < sort_b.get_sort_value()


static func after_than(a: TabTrackerItem, b: TabTrackerItem) -> bool:
	return !before_than(a, b)
