class_name NumberUtils

const SCIENTIFIC_SUFFIX: Array[String] = [
	"", "", "", "", "K", "K", "K", "M", "M", "M", "B", "B", "B", "t", "t", "t", "q", "q", "q"
]

const SCIENTIFIC_MAGNITUDE: Array[int] = [
	0,
	0,
	0,
	0,
	1000,
	1000,
	1000,
	1000000,
	1000000,
	1000000,
	1000000000,
	1000000000,
	1000000000,
	1000000000000,
	1000000000000,
	1000000000000,
	1000000000000000,
	1000000000000000,
	1000000000000000,
]


static func format_zero_padding(number: int, length: int) -> String:
	return "%0*d" % [length, number]


## converts number to comma separated groups
## example: convers number 123456789 to "123,456,789" if group_size is 3
static func format_number(number: int, separator: String = ",", group_size: int = 3) -> String:
	if number >= Limits.GLOBAL_MAX_AMOUNT:
		return "Infinity"
	if number <= -Limits.GLOBAL_MAX_AMOUNT:
		return "-Infinity"

	var is_negative: bool = number < 0
	if is_negative:
		number *= -1

	var input: String = str(number)
	var out: Array[String] = []
	var length: int = input.length()
	for i: int in length:
		out.append(input[length - i - 1])
		if i < length - 1 and (i + 1) % group_size == 0:
			out.append(separator)
	out.reverse()

	var output: String = "".join(out)
	if is_negative:
		output = "-" + output
	return output


## converts number to maginute suffix: K = 10^3, M = 10^6, B = 10^9, t = 10^12, q = 10^15
## example: converts number 123456 to "123.4K" if length is 4 or "123.456K" if length is 6 or more
static func format_number_scientific(number: int, length: int = 4) -> String:
	if number >= Limits.GLOBAL_MAX_AMOUNT:
		return "Infinity"
	if number <= -Limits.GLOBAL_MAX_AMOUNT:
		return "-Infinity"

	var is_negative: bool = number < 0
	if is_negative:
		number *= -1

	var output: String = str(number)
	var digits: int = output.length()
	var order: int = min(digits, min(SCIENTIFIC_SUFFIX.size(), SCIENTIFIC_MAGNITUDE.size()) - 1)
	var suffix: String = SCIENTIFIC_SUFFIX[order]
	if suffix.length() == 0:
		if is_negative:
			output = "-" + output
		return output

	var magnitude: int = SCIENTIFIC_MAGNITUDE[order]
	var part: int = number / magnitude
	var remainder: int = number % magnitude
	output = str(part)
	var part_digits: int = output.length()
	var remainder_digits: int = digits - part_digits

	var digits_room: int = length - part_digits
	if digits_room > 0:
		var decimal: String = format_zero_padding(remainder, remainder_digits)
		var digits_decimal: int = len(decimal)
		decimal = decimal.substr(0, min(digits_room, digits_decimal))
		output = output + "." + decimal

	if is_negative:
		output = "-" + output
	return output + suffix


static func format_number_scientific_list(vals: Array, l: int = 4) -> Array:
	return vals.map(func(val: int) -> String: return NumberUtils.format_number_scientific(val, l))


static func is_valid_int_64(input_string: String) -> bool:
	# The built-in function only checks for digits, not if
	# the value will overflow a 64-bit integer
	if not input_string.is_valid_int():
		return false

	var number_string: String = input_string.lstrip("0")
	if number_string == "":
		number_string = "0"

	var max_int_string: String = str(Limits.GLOBAL_MAX_INT_64)
	var min_int_string: String = str(Limits.GLOBAL_MIN_INT_64)

	if number_string.length() > max_int_string.length():
		return false
	elif number_string.length() < max_int_string.length():
		return true

	if number_string.begins_with("-"):
		return number_string >= min_int_string
	else:
		return number_string <= max_int_string
