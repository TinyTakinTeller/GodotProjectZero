class_name Limits

const GLOBAL_MAX_INT_64: int = 9223372036854775807
const GLOBAL_MIN_INT_64: int = -9223372036854775808
const GLOBAL_MAX_AMOUNT: int = 1000000000000000000  # = 10^18 = 1Q = One Quintillion = 1000q


## return reduced additional amount so that current + additional does not exceed GLOBAL_MAX_AMOUNT
static func safe_addition_factor(current: int, additional: int) -> int:
	var safe_sum: int = safe_addition(current, additional)
	var safe_current: int = max(min(current, Limits.GLOBAL_MAX_AMOUNT), -Limits.GLOBAL_MAX_AMOUNT)
	var safe_additional: int = safe_sum - safe_current
	return safe_additional


## return a + b except when it rounds to GLOBAL_MAX_AMOUNT (or negative sign) to prevent overflow
static func safe_addition(a: int, b: int) -> int:
	a = max(min(a, Limits.GLOBAL_MAX_AMOUNT), -Limits.GLOBAL_MAX_AMOUNT)
	b = max(min(b, Limits.GLOBAL_MAX_AMOUNT), -Limits.GLOBAL_MAX_AMOUNT)
	var sum: int = max(min(a + b, Limits.GLOBAL_MAX_AMOUNT), -Limits.GLOBAL_MAX_AMOUNT)
	return sum


## returns a * b except when it rounds to GLOBAL_MAX_AMOUNT (or negative sign) to prevent overflow
static func safe_multiplication(a: int, b: int) -> int:
	var sgn: int = -1 if (a < 0 and b > 0) or (a > 0 and b < 0) else 1
	a = abs(a)
	b = abs(b)
	var digits_limit: float = log(Limits.GLOBAL_MAX_AMOUNT)
	var digits_a: float = log(a)
	var digits_b: float = log(b)
	var product: int = Limits.GLOBAL_MAX_AMOUNT
	if (digits_a + digits_b) < digits_limit:
		product = a * b
	return product * sgn
