extends MarginContainer
class_name ResourceTracker

@onready var resource_v_box_container: VBoxContainer = %ResourceVBoxContainer

@export var resource_item_scene: PackedScene


func _ready() -> void:
	_load_from_save_file()
	SignalBus.resource_updated.connect(_on_resource_updated)


func _load_from_save_file() -> void:
	_clear_items()
	for resources_id: String in SaveFile.resources:
		var amount: int = SaveFile.resources[resources_id]
		_add_resource(resources_id, amount)


func _set_resources(resources: Dictionary) -> void:
	_clear_items()
	for id: String in resources:
		_add_resource(id, resources[id])


func _add_resource(id: String, amount: int) -> ResourceTrackerItem:
	var resource_generator: ResourceGenerator = Resources.resource_generators[id]
	if resource_generator.hidden:
		return

	var resource_item: ResourceTrackerItem = (
		resource_item_scene.instantiate() as ResourceTrackerItem
	)
	resource_item.set_resource(resource_generator)
	NodeUtils.add_child_sorted(
		resource_item, resource_v_box_container, ResourceTrackerItem.before_than
	)
	resource_item.display_resource(amount)
	return resource_item


func _update_resource(id: String, amount: int, change: int, source_id: String) -> void:
	for updated_resource: ResourceTrackerItem in resource_v_box_container.get_children():
		if updated_resource.get_id() == id:
			updated_resource.display_resource(amount)
			if change > 0:
				SignalBus.resource_ui_updated.emit(updated_resource, amount, change, source_id)
			return
	var new_resource: ResourceTrackerItem = _add_resource(id, amount)
	if new_resource != null and change > 0:
		SignalBus.resource_ui_updated.emit(new_resource, amount, change, source_id)


func _clear_items() -> void:
	NodeUtils.clear_children(resource_v_box_container)


func _on_resource_updated(id: String, total: int, amount: int, source_id: String) -> void:
	_update_resource(id, total, amount, source_id)
