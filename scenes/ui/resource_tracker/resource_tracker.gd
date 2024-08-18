class_name ResourceTracker
extends MarginContainer

@export var resource_item_scene: PackedScene

@onready var resource_v_box_container: VBoxContainer = %ResourceVBoxContainer
@onready var title_label: Label = %TitleLabel

###############
## overrides ##
###############


func _ready() -> void:
	_set_ui_labels()
	_connect_signals()
	_load_from_save_file()


#############
## helpers ##
#############


func _set_ui_labels() -> void:
	var ui_resource_storage: String = Locale.get_ui_label("resource_storage")
	title_label.text = ui_resource_storage


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
	var resource_generator: ResourceGenerator = Resources.resource_generators.get(id, null)
	if resource_generator == null:
		return
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


func _play_blink_red_animation(resource_generator_id: String) -> void:
	for resource_tracker_item: ResourceTrackerItem in resource_v_box_container.get_children():
		if resource_tracker_item.get_id() == resource_generator_id:
			resource_tracker_item.play_modulate_red_simple_tween_animation()
			return
	var new_resource_tracker_item: ResourceTrackerItem = _add_resource(resource_generator_id, 0)
	if new_resource_tracker_item != null:
		new_resource_tracker_item.play_modulate_red_simple_tween_animation()


func _clear_items() -> void:
	NodeUtils.clear_children(resource_v_box_container)


##############
## handlers ##
##############


func _handle_on_resources_unpaid(costs: Dictionary) -> void:
	for resource_generator_id: String in costs:
		var cost: int = costs[resource_generator_id]
		if SaveFile.resources.get(resource_generator_id, 0) < cost:
			_play_blink_red_animation(resource_generator_id)


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.resource_updated.connect(_on_resource_updated)
	SignalBus.progress_button_unpaid.connect(_on_progress_button_unpaid)
	SignalBus.substance_craft_button_unpaid.connect(_on_substance_craft_button_unpaid)


func _on_resource_updated(id: String, total: int, amount: int, source_id: String) -> void:
	_update_resource(id, total, amount, source_id)


func _on_progress_button_unpaid(resource_generator: ResourceGenerator, source: String) -> void:
	if source != "harvest_forest":
		_handle_on_resources_unpaid(resource_generator.costs)


func _on_substance_craft_button_unpaid(substance_data: SubstanceData) -> void:
	_handle_on_resources_unpaid(substance_data.get_resource_costs())
