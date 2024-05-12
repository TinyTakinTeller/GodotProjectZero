class_name RandomUtils


static func pick_random_weighted_item(items: Dictionary, weights_sum: int) -> String:
	var roll: int = randi() % weights_sum
	for n: String in items:
		if roll < items[n]:
			return n
		roll -= items[n]
	return items[items.size() - 1]
