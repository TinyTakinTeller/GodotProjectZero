extends Node

@onready var tab_tracker: TabTracker = %TabTracker
@onready var ui: Control = %UI

###############
## overrides ##
###############


func _ready() -> void:
	_initialize()
	_connect_signals()

	if Game.PARAMS["debug_logs"]:
		print("_READY: " + self.get_name())


#############
## helpers ##
#############


func _initialize() -> void:
	tab_tracker.change_tab(0)


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.set_ui_theme.connect(_on_set_ui_theme)
	self.ready.connect(_on_ready)

func _on_set_ui_theme(theme: Resource) -> void:
	ui.theme = theme

func _on_ready() -> void:
	SignalBus.main_ready.emit()
