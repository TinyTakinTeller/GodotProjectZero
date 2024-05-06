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


func _add_resource(id: String, amount: int) -> void:
	var resource_item: ResourceTrackerItem = (
		resource_item_scene.instantiate() as ResourceTrackerItem
	)
	resource_item.set_resource(id)
	NodeUtils.add_child_sorted(resource_item, resource_v_box_container, ResourceTracker.before_than)
	resource_item.display_resource(amount)


func _update_resources(resources: Dictionary) -> void:
	for id: String in resources:
		_update_resource(id, resources[id])


func _update_resource(id: String, amount: int) -> void:
	for updated_resource: ResourceTrackerItem in resource_v_box_container.get_children():
		if updated_resource._resource_id == id:
			updated_resource.display_resource(amount)
			return
	_add_resource(id, amount)


func _clear_items() -> void:
	NodeUtils.clear_children(resource_v_box_container)


func _on_resource_updated(id: String, total: int, _amount: int) -> void:
	_update_resource(id, total)


static func before_than(a: ResourceTrackerItem, b: ResourceTrackerItem) -> bool:
	var sort_a: ResourceGenerator = Resources.resource_generators.get(a._resource_id, null)
	var sort_b: ResourceGenerator = Resources.resource_generators.get(b._resource_id, null)
	if sort_a == null:
		return true
	if sort_b == null:
		return false
	return sort_a.sort_value < sort_b.sort_value
