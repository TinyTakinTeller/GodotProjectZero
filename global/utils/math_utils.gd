class_name MathUtils


## closed form for (y_0) + (y_0 + c) + (y_0 + 2 * c) + (y_0 + 3 * c) + ...
static func dual_sum(y0: int, c: int, n: int) -> int:
	return (n * y0) + (((n * (n + 1)) / 2) * c)


## overflow protected version of 'dual_additive'
static func safe_dual_sum(y0: int, c: int, n: int) -> int:
	var yf: int = Limits.safe_mult(n, y0)
	var cf: int = Limits.safe_mult(Limits.safe_mult(n + 1, n) / 2, c)
	return Limits.safe_add(yf, cf)


# 'dual_additive' divided by f
static func dual_sum_normalized(y0: float, c: float, n: float, f: float) -> float:
	return ((n / f) * y0) + ((((n / f) * (n + 1)) / 2) * c)
