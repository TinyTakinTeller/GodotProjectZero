extends Node

@onready var tab_bar: TabBar = %TabBar
@onready var world_screen: MarginContainer = %WorldScreen
@onready var managment_screen: MarginContainer = %ManagmentScreen
@onready var unknown_screen: MarginContainer = %UnknownScreen


func _ready() -> void:
	_change_screen(0)
	tab_bar.tab_changed.connect(_on_tab_changed)


func _change_screen(tab: int) -> void:
	_hide_screens()
	if tab == 0:
		world_screen.visible = true
	elif tab == 1:
		managment_screen.visible = true
	else:
		unknown_screen.visible = true


func _hide_screens() -> void:
	world_screen.visible = false
	unknown_screen.visible = false
	managment_screen.visible = false


func _on_tab_changed(tab: int) -> void:
	_change_screen(tab)
