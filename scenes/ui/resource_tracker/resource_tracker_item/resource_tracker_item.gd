extends MarginContainer
class_name ResourceTrackerItem

@onready var amount_label: Label = %AmountLabel
@onready var income_label: Label = %IncomeLabel
@onready var modulate_red_simple_tween: SimpleTween = %ModulateRedSimpleTween

var _resource_generator: ResourceGenerator


func _ready() -> void:
	amount_label.text = ""
	income_label.text = ""
	SignalBus.worker_efficiency_updated.connect(_on_worker_efficiency_updated)
	SignalBus.progress_button_unpaid.connect(_on_progress_button_unpaid)


func get_id() -> String:
	return _resource_generator.id


func set_resource(resource_generator: ResourceGenerator) -> void:
	_resource_generator = resource_generator


func display_resource(amount: int) -> void:
	var resource_name: String = _resource_generator.get_display_name()
	amount_label.text = "{name}: {amount}".format({"name": resource_name, "amount": amount})


func set_passive(amount: int) -> void:
	if amount > 0:
		income_label.text = "+{amount}".format({"amount": amount})
		income_label.modulate = Color(0.392, 0.878, 0, 1)
	elif amount < 0:
		income_label.text = "{amount}".format({"amount": amount})
		income_label.modulate = Color(0.878, 0, 0.392, 1)
	else:
		income_label.text = ""


func _modulate_red_simple_tween_method(animation_percent: float) -> void:
	amount_label.modulate = Color(1, animation_percent, animation_percent, 1)


func _on_worker_efficiency_updated(efficiencies: Dictionary) -> void:
	var id: String = get_id()
	set_passive(efficiencies.get(id, 0))


func _on_progress_button_unpaid(resource_generator: ResourceGenerator) -> void:
	var id: String = get_id()
	if resource_generator.costs.has(id):
		if SaveFile.resources.get(id, 0) < resource_generator.costs[id]:
			modulate_red_simple_tween.play_animation()


static func before_than(a: ResourceTrackerItem, b: ResourceTrackerItem) -> bool:
	var sort_a: ResourceGenerator = Resources.resource_generators.get(a.get_id(), null)
	var sort_b: ResourceGenerator = Resources.resource_generators.get(b.get_id(), null)
	if sort_a == null:
		return true
	if sort_b == null:
		return false
	return sort_a.sort_value < sort_b.sort_value
