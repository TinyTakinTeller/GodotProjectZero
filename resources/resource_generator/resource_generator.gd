extends Resource
class_name ResourceGenerator

@export var id: String
@export var amount: int = 1
@export var cooldown: float = 1
@export var cost: Dictionary
@export var label: String
@export var title: String
@export var flavor: String


func get_amount() -> int:
	return amount


func get_cooldown() -> float:
	return cooldown


func get_cost() -> Dictionary:
	return cost


func get_label() -> String:
	return label


func get_title() -> String:
	return title


func get_info() -> String:
	var info: String = "Cost: "
	if cost.size() == 0:
		return flavor
	info += ("%s " + (", %s ".join(cost.keys()))) % cost.values()
	return info
