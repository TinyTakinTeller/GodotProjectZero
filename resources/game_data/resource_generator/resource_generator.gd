extends Resource
class_name ResourceGenerator

@export var sort_value: int = 0
@export var id: String
@export var amount: int = 1
@export var cooldown: float = 1
@export var costs: Dictionary
@export var cost_scales: Dictionary
@export var label: String
@export var title: String
@export var flavor: String


func get_amount() -> int:
	return amount


func get_cooldown() -> float:
	return cooldown


func get_costs() -> Dictionary:
	return costs


func get_scaled_costs(level: int) -> Dictionary:
	if cost_scales.size() == 0:
		return costs
	var scaled_costs: Dictionary = {}
	for cost_id: String in costs.keys():
		var scaled_cost_amount: int = get_scaled_cost(cost_id, level)
		scaled_costs[cost_id] = scaled_cost_amount
	return scaled_costs


func get_scaled_cost(cost_id: String, level: int) -> int:
	var base_cost: int = costs[cost_id]
	if !cost_scales.has(cost_id):
		return base_cost
	var cost_function: CostFunction = cost_scales[cost_id]
	return cost_function.get_cost(base_cost, level)


func get_label() -> String:
	return label


func get_title() -> String:
	return title


func get_info(level: int) -> String:
	var scaled_costs: Dictionary = get_scaled_costs(level)
	if scaled_costs.size() == 0:
		return flavor
	var info: String = "Cost: "
	info += ("%s " + (", %s ".join(scaled_costs.keys()))) % scaled_costs.values()
	info += " - " + flavor
	return info
