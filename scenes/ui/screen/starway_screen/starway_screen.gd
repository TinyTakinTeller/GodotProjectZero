class_name StarwayScreen extends MarginContainer

const TAB_DATA_ID: String = "starway"

@onready var progress_bar_margin_container: BasicProgressBar = %ProgressBarMarginContainer

###############
## overrides ##
###############


func _ready() -> void:
	_initialize()
	_connect_signals()
	_load_from_save_file()


#############
## helpers ##
#############


func _initialize() -> void:
	_set_infinity_progress()


func _load_from_save_file() -> void:
	pass


func _set_infinity_progress() -> void:
	var infinity_progress: Dictionary = PrestigeController.get_infinity_progress()
	var max_infinity_count: int = infinity_progress["max_infinity_count"]
	var max_amount: int = infinity_progress["max_amount"]
	var max_resource_id: String = infinity_progress["max_resource_id"]
	var max_resource_name: String = infinity_progress["max_resource_name"]
	var infinity_count: int = infinity_progress["infinity_count"]

	if !StringUtils.is_not_empty(max_resource_id):
		progress_bar_margin_container.visible = false
		return
	progress_bar_margin_container.visible = true

	var progress: float
	var progress_label: String
	if infinity_count >= max_infinity_count:
		progress_label = "MAX"
		progress = 1.0
	elif infinity_count <= 0:
		progress = log(max_amount) / log(Limits.GLOBAL_MAX_AMOUNT)
		progress_label = Locale.get_ui_label("infinity_progress_1").format(
			{"0": "%2.2f" % (progress * 100.0), "1": max_resource_name}
		)
	else:
		progress = float(infinity_count) / float(max_infinity_count)
		progress_label = Locale.get_ui_label("infinity_progress_2").format(
			{"1": infinity_count, "2": max_infinity_count}
		)

	progress_bar_margin_container.set_display(progress, progress_label, ColorSwatches.BLUE)


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.tab_changed.connect(_on_tab_changed)
	SignalBus.resource_updated.connect(_on_resource_updated)


func _on_tab_changed(tab_data: TabData) -> void:
	if tab_data.id == TAB_DATA_ID:
		visible = true
	else:
		visible = false


func _on_resource_updated(_id: String, _total: int, _amount: int, _source_id: String) -> void:
	_set_infinity_progress()
