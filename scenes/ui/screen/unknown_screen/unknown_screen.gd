extends MarginContainer

const TAB_DATA_ID: String = "unknown"

@onready var grid_container: GridContainer = %GridContainer


func _ready() -> void:
	SignalBus.tab_changed.connect(_on_tab_changed)


func _on_tab_changed(tab_data: TabData) -> void:
	if tab_data.id == TAB_DATA_ID:
		visible = true
	else:
		visible = false
