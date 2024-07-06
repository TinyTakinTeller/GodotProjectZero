extends MarginContainer

const TAB_DATA_ID: String = "soul"

@onready var screen_h_box_container: HBoxContainer = %ScreenHBoxContainer

@export var substance_button_scene: PackedScene

var vbox_containers: Array[VBoxContainer] = []

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
	for node: Node in screen_h_box_container.get_children():
		if is_instance_of(node, VBoxContainer):
			vbox_containers.append(node as VBoxContainer)


func _load_from_save_file() -> void:
	_clear_items()
	for enemy_id: String in SaveFile.get_enemy_ids():
		_load_substance_button(enemy_id)


func _load_substance_button(enemy_id: String) -> void:
	var enemy_data: EnemyData = Resources.enemy_datas[enemy_id]
	_add_substance_button(enemy_data)


func _add_substance_button(enemy_data: EnemyData) -> SubstanceButton:
	var substance_button: SubstanceButton = substance_button_scene.instantiate() as SubstanceButton
	substance_button.set_data(enemy_data)
	NodeUtils.add_child_sorted(
		substance_button, vbox_containers[enemy_data.column], SubstanceButton.before_than
	)
	substance_button.display_data()
	return substance_button


func _clear_items() -> void:
	for vbox_container: VBoxContainer in vbox_containers:
		NodeUtils.clear_children_of(vbox_container, SubstanceButton)


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.tab_changed.connect(_on_tab_changed)
	SignalBus.deaths_door_resolved.connect(_on_deaths_door_resolved)


func _on_tab_changed(tab_data: TabData) -> void:
	if tab_data.id == TAB_DATA_ID:
		visible = true
	else:
		visible = false


func _on_deaths_door_resolved(
	enemy_data: EnemyData, _new_enemy_data: EnemyData, _option: int
) -> void:
	if !enemy_data.is_last():
		_add_substance_button(enemy_data)
