extends MarginContainer

@onready var title_label: Label = %TitleLabel
@onready var info_label: Label = %InfoLabel

var info_id: String


func _ready() -> void:
	_clear()
	SignalBus.progress_button_hover.connect(_on_progress_button_hover)
	SignalBus.manager_button_hover.connect(_on_manager_button_hover)
	SignalBus.resource_updated.connect(_on_resource_updated)


func _clear() -> void:
	_handle_hover("", "")


func _handle_hover(title: String, info: String) -> void:
	title_label.text = title
	info_label.text = info


func _on_progress_button_hover(resource_generator: ResourceGenerator) -> void:
	var id: String = resource_generator.id
	var level: int = SaveFile.resources.get(id, 0) + 1
	info_id = id
	_handle_hover(resource_generator.get_title(), resource_generator.get_info(level))


func _on_manager_button_hover(worker_role: WorkerRole) -> void:
	var id: String = worker_role.id
	info_id = id
	_handle_hover(worker_role.get_title(), worker_role.get_info())


func _on_resource_updated(id: String, _total: int, _amount: int) -> void:
	if id == info_id:
		var resource_generator: ResourceGenerator = Resources.resource_generators[id]
		_on_progress_button_hover(resource_generator)
