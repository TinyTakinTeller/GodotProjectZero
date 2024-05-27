class_name ArrayUtils


## return true if a shares an element with b
static func intersects(a: Array, b: Array) -> bool:
	for e: Variant in a:
		if b.has(e):
			return true
	return false
