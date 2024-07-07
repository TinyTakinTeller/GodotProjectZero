class_name Limits

const GLOBAL_MAX_INT_64: int = 9223372036854775807
const GLOBAL_MIN_INT_64: int = -9223372036854775808
const GLOBAL_MAX_AMOUNT: int = 1000000000000000000  # = 10^18 = 1Q = One Quintillion = 1000q


## return reduced additional amount so that current + additional does not exceed GLOBAL_MAX_AMOUNT
static func safe_add_factor(current: int, addition: int) -> int:
	var safe_sum: int = safe_add(current, addition)
	var safe_current: int = max(min(current, Limits.GLOBAL_MAX_AMOUNT), -Limits.GLOBAL_MAX_AMOUNT)
	var safe_addition: int = safe_sum - safe_current
	return safe_addition


## return a + b except when it rounds to GLOBAL_MAX_AMOUNT (or negative sign) to prevent overflow
static func safe_add(a: int, b: int, extended_limit_quantity: int = 0) -> int:
	var limit: int = extended_limit_quantity + Limits.GLOBAL_MAX_AMOUNT
	a = max(min(a, limit), -limit)
	b = max(min(b, limit), -limit)
	return max(min(a + b, limit), -limit)


## returns a * b except when it rounds to GLOBAL_MAX_AMOUNT (or negative sign) to prevent overflow
static func safe_mult(a: int, b: int) -> int:
	var sgn: int = -1 if (a < 0 and b > 0) or (a > 0 and b < 0) else 1
	a = abs(a)
	b = abs(b)
	var digits_limit: float = log(Limits.GLOBAL_MAX_AMOUNT)
	var digits_a: float = log(a)
	var digits_b: float = log(b)

	if (digits_a + digits_b) < digits_limit:
		return a * b * sgn
	return Limits.GLOBAL_MAX_AMOUNT * sgn
