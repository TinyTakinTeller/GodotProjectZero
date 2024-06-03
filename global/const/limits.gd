class_name Limits

const GLOBAL_MAX_INT_64: int = 9223372036854775807
const GLOBAL_MAX_AMOUNT: int = 1000000000000000000  # = 10^18 = 1Q = One Quintillion = 1000q


static func check_global_max_amount(current: int, additional: int) -> int:
	var safe_current: int = min(current, Limits.GLOBAL_MAX_AMOUNT)
	var safe_additional: int = min(additional, Limits.GLOBAL_MAX_AMOUNT)
	var safe_next: int = min(safe_current + safe_additional, Limits.GLOBAL_MAX_AMOUNT)
	var delta: int = safe_next - safe_current
	return delta
