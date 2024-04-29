extends MarginContainer

@onready var resource_v_box_container: VBoxContainer = %ResourceVBoxContainer

@export var resource_item_scene: PackedScene


func _ready() -> void:
	_clear_items()
	SignalBus.resource_updated.connect(_on_resource_updated)


func set_resources(resources: Dictionary) -> void:
	_clear_items()
	for id: String in resources:
		add_resource(id, resources[id])


func add_resource(id: String, amount: int) -> void:
	var resource_item: ResourceTrackerItem = _add_item()
	resource_item.set_resource(id, amount)


func update_resources(resources: Dictionary) -> void:
	for id: String in resources:
		update_resource(id, resources[id])


func update_resource(id: String, amount: int) -> void:
	for n: ResourceTrackerItem in resource_v_box_container.get_children():
		if n._id == id:
			n.set_resource(id, amount)
			return
	add_resource(id, amount)


func _add_item() -> ResourceTrackerItem:
	var resource_item: ResourceTrackerItem = (
		resource_item_scene.instantiate() as ResourceTrackerItem
	)
	resource_v_box_container.add_child(resource_item)
	return resource_item


func _clear_items() -> void:
	NodeUtils.clear_children(resource_v_box_container)


func _on_resource_updated(id: String, total: int, _amount: int) -> void:
	update_resource(id, total)
