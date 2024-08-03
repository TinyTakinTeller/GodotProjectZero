class_name SubstanceData
extends Resource

@export var color: Color = Color.BLACK
@export var order: int = 0
@export var id: String
@export var image_id: String
@export var resource_costs: Dictionary
@export var category_id: String = "special"
@export var hidden: bool = true


func is_color() -> bool:
	return color != Color.BLACK


func get_color() -> Color:
	return color


func get_sort_value() -> int:
	return order


func get_order() -> int:
	return order


func get_id() -> String:
	return id


func get_image_texture() -> Resource:
	return Resources.image.get(image_id, null)


func get_resource_costs() -> Dictionary:
	return resource_costs


func is_craftable() -> bool:
	return resource_costs != null && !resource_costs.is_empty()


func get_display_title() -> String:
	var title: String = Locale.get_substance_text(id + "_title")
	if StringUtils.is_not_empty(title):
		return title
	return StringUtils.humanify_string(id)


func get_display_info() -> String:
	return Locale.get_substance_text(id + "_info")


func get_craft_title() -> String:
	var craft_title: String = Locale.get_substance_text(id + "_craft_title")
	if StringUtils.is_not_empty(craft_title):
		return craft_title
	return get_display_title()


func get_craft_info() -> String:
	var info: String = ""

	if resource_costs.size() > 0:
		info += Locale.get_ui_label("cost") + ": "
		var resource_names: Array = ResourceGenerator.get_display_names_of(resource_costs.keys())
		info += (", -%s " + (", -%s ".join(resource_names))) % resource_costs.values()

	var craft_info: String = Locale.get_substance_text(id + "_craft_info")
	if StringUtils.is_not_empty(craft_info):
		info += " - " + craft_info

	if StringUtils.is_not_empty(info):
		return info
	return get_display_info()


func get_category_id() -> String:
	return category_id


func is_hidden() -> bool:
	return hidden
