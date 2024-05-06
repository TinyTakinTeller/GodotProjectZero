extends CostFunction


func get_cost(base_cost: int, level: int) -> int:
	return base_cost * level
