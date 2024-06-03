class_name ArrayUtils


## return true if a shares an element with b
static func intersects(a: Array, b: Array) -> bool:
	for e: Variant in a:
		if b.has(e):
			return true
	return false


static func max_element(arr: Array) -> Variant:
	return arr.reduce(func(a: Variant, b: Variant) -> Variant: return a if a > b else b, arr[0])


static func min_element(arr: Array) -> Variant:
	return arr.reduce(func(a: Variant, b: Variant) -> Variant: return a if a < b else b, arr[0])
