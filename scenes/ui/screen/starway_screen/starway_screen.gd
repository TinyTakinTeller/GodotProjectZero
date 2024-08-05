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
	progress_bar_margin_container.visible = false
	# progress_bar_margin_container.set_display(0.27, "27%", ColorSwatches.BLUE) # TODO


func _load_from_save_file() -> void:
	pass


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.tab_changed.connect(_on_tab_changed)


func _on_tab_changed(tab_data: TabData) -> void:
	if tab_data.id == TAB_DATA_ID:
		visible = true
	else:
		visible = false
