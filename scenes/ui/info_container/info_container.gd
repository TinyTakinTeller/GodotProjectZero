extends MarginContainer

@onready var title_label: Label = %TitleLabel
@onready var info_label: Label = %InfoLabel


func _ready() -> void:
	_clear()
	SignalBus.progress_button_hover.connect(_on_progress_button_hover)
	SignalBus.manager_button_hover.connect(_on_manager_button_hover)


func _clear() -> void:
	_handle_hover("", "")


func _handle_hover(title: String, info: String) -> void:
	title_label.text = title
	info_label.text = info


func _on_progress_button_hover(resource_generator: ResourceGenerator) -> void:
	_handle_hover(resource_generator.get_title(), resource_generator.get_info())


func _on_manager_button_hover(worker_role: WorkerRole) -> void:
	_handle_hover(worker_role.get_title(), worker_role.get_info())
