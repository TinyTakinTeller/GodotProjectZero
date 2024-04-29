extends MarginContainer
class_name ResourceTrackerItem

@onready var amount_label: Label = %AmountLabel
@onready var passive_income_label: Label = %PassiveIncomeLabel

var _id: String


func _ready() -> void:
	amount_label.text = ""
	passive_income_label.text = ""
	SignalBus.worker_efficiency_updated.connect(_on_worker_efficiency_updated)


func set_resource(id: String, amount: int) -> void:
	_id = id
	amount_label.text = "{id}: {amount}".format({"id": id, "amount": amount})


func set_passive(amount: int) -> void:
	if amount > 0:
		passive_income_label.text = "+{amount}".format({"amount": amount})
	elif amount < 0:
		passive_income_label.text = "{amount}".format({"amount": amount})
	else:
		passive_income_label.text = ""


func _on_worker_efficiency_updated(efficiencies: Dictionary) -> void:
	set_passive(efficiencies.get(_id, 0))
