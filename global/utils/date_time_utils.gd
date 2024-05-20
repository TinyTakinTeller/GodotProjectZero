class_name DateTimeUtils


static func with_timezone(datetime: Dictionary, timezone: Dictionary) -> Dictionary:
	var unix: int = Time.get_unix_time_from_datetime_dict(datetime)
	unix += timezone["bias"] * 60
	return Time.get_datetime_dict_from_unix_time(unix)


static func format_datetime(d: Dictionary, format: String = "{z}.{x}.{y} {h}:{m}:{s}") -> String:
	var y: String = with_zero_prefix(d.get("year", 0))
	var x: String = with_zero_prefix(d.get("month", 0))
	var z: String = with_zero_prefix(d.get("day", 0))
	var h: String = with_zero_prefix(d.get("hour", 0))
	var m: String = with_zero_prefix(d.get("minute", 0))
	var s: String = with_zero_prefix(d.get("second", 0))
	return format.format({"y": y, "x": x, "z": z, "h": h, "m": m, "s": s})


static func format_seconds(amount: int, format: String = "{h}h : {m}m : {s}s") -> String:
	var hours: int = amount / 3600
	var minutes: int = (amount / 60) % 60
	var seconds: int = amount % 60
	var h: String = str(hours)
	var m: String = with_zero_prefix(minutes)
	var s: String = with_zero_prefix(seconds)
	return format.format({"h": h, "m": m, "s": s})


static func with_zero_prefix(n: int) -> String:
	return str(n) if n > 9 else "0" + str(n)


static func datetime_to_int(d: Dictionary) -> int:
	return (
		0
		+ (10000000000 * d.get("year", 0))
		+ (100000000 * d.get("month", 0))
		+ (1000000 * d.get("day", 0))
		+ (10000 * d.get("hour", 0))
		+ (100 * d.get("minute", 0))
		+ d.get("second", 0)
	)


static func datetime_before_than(a: Dictionary, b: Dictionary) -> bool:
	return datetime_to_int(a) < datetime_to_int(b)
