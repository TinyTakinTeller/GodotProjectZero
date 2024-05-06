extends MarginContainer
class_name ResourceTrackerItem

@onready var amount_label: Label = %AmountLabel
@onready var income_label: Label = %IncomeLabel

var _resource_id: String


func _ready() -> void:
	amount_label.text = ""
	income_label.text = ""
	SignalBus.worker_efficiency_updated.connect(_on_worker_efficiency_updated)


func set_resource(resource_id: String) -> void:
	_resource_id = resource_id


func display_resource(amount: int) -> void:
	amount_label.text = "{id}: {amount}".format({"id": _resource_id, "amount": amount})


func set_passive(amount: int) -> void:
	if amount > 0:
		income_label.text = "+{amount}".format({"amount": amount})
		income_label.modulate = Color(0.392, 0.878, 0, 1)
	elif amount < 0:
		income_label.text = "{amount}".format({"amount": amount})
		income_label.modulate = Color(0.878, 0, 0.392, 1)
	else:
		income_label.text = ""


func _on_worker_efficiency_updated(efficiencies: Dictionary) -> void:
	set_passive(efficiencies.get(_resource_id, 0))
