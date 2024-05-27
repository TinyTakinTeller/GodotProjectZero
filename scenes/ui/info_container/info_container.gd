extends MarginContainer

@onready var title_label: Label = %TitleLabel
@onready var info_label: Label = %InfoLabel

var info_id: String

###############
## overrides ##
###############


func _ready() -> void:
	_initialize()
	_connect_signals()


#############
## helpers ##
#############


func _toggle_wiggle_shader(enabled: bool) -> void:
	title_label.material.set_shader_parameter("enabled", enabled)
	info_label.material.set_shader_parameter("enabled", enabled)


##############
## handlers ##
##############


func _initialize() -> void:
	_handle_on_hover("   ", "   ")


func _handle_on_hover(title: String, info: String) -> void:
	if title.length() < 2 or info.length() < 2:
		return
	title_label.text = title
	info_label.text = info


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.progress_button_hover.connect(_on_progress_button_hover)
	SignalBus.manager_button_hover.connect(_on_manager_button_hover)
	SignalBus.enemy_hover.connect(_on_enemy_hover)
	SignalBus.resource_updated.connect(_on_resource_updated)


func _on_progress_button_hover(resource_generator: ResourceGenerator) -> void:
	var id: String = resource_generator.id
	var level: int = SaveFile.resources.get(id, 0) + 1
	info_id = id
	_handle_on_hover(resource_generator.get_title(), resource_generator.get_info(level))
	_toggle_wiggle_shader(false)


func _on_manager_button_hover(worker_role: WorkerRole) -> void:
	var id: String = worker_role.id
	info_id = id
	_handle_on_hover(worker_role.get_title(), worker_role.get_info())
	_toggle_wiggle_shader(false)


func _on_enemy_hover(enemy_data: EnemyData) -> void:
	var id: String = enemy_data.id
	info_id = id
	_handle_on_hover(enemy_data.get_title(), enemy_data.get_info())
	_toggle_wiggle_shader(true)


func _on_resource_updated(id: String, _total: int, _amount: int, _source_id: String) -> void:
	if id == info_id:
		var resource_generator: ResourceGenerator = Resources.resource_generators[id]
		_on_progress_button_hover(resource_generator)
