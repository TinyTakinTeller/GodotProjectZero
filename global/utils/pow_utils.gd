class_name PowUtils


static func pow_int(base: int, exponent: int) -> int:
	if base == 0:
		return 0
	if base == 1:
		return 1
	if exponent == 0:
		return 1

	var result: int = 1
	for i: int in range(exponent):
		result *= base
	return result
