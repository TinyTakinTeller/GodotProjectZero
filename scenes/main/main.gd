extends Node

@onready var tab_tracker: TabTracker = %TabTracker
@onready var ui: Control = $UI


func _ready() -> void:
	tab_tracker._on_tab_changed(0)
	SignalBus.set_ui_theme.connect(_on_set_ui_theme)


func _on_set_ui_theme(theme: Resource) -> void:
	ui.theme = theme
