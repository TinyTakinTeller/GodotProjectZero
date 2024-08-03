class_name StringUtils

const DIGITS: String = "0123456789"
const LETTERS: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
const COMMON: String = "-_" + LETTERS + DIGITS
const SPECIAL: String = " !\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~"
const ASCII: String = COMMON + SPECIAL


func random_string(length: int, chars: String = COMMON) -> String:
	var result: String = ""
	for i: int in range(length):
		result += chars[randi() % chars.length()]
	return result


static func is_not_empty(string: String) -> bool:
	return string != null and string.length() != 0


static func trim_end(text: String, max_length: int) -> String:
	return text.substr(0, min(text.length(), max_length))


static func sanitize_text(
	text: String, allowed: String, max_length: int = -1, default_empty: String = ""
) -> String:
	text = StringUtils.sanitize(text, allowed)
	if max_length > -1:
		text = StringUtils.trim_end(text, max_length)
	if text.length() == 0:
		text = default_empty
	return text


static func sanitize(text: String, allowed: String) -> String:
	var output: String = ""
	for c in text:
		if allowed.contains(c):
			output += c
	return output


static func increment_int_suffix(text: String, forbidden: Array) -> String:
	var int_suffix: String = ""
	for i in range(text.length()):
		var c: String = text[text.length() - 1 - i]
		if !DIGITS.contains(c):
			break
		int_suffix = c + int_suffix
	if int_suffix == "":
		int_suffix = "0"

	var text_prefix: String = text.trim_suffix(int_suffix)
	var int_suffix_value: int = int(int_suffix)
	var increment: int = 0
	var output: String = text_prefix + str(int_suffix_value + increment)
	while output in forbidden:
		increment += 1
		output = text_prefix + str(int_suffix_value + increment)

	return output


static func humanify_string(s: String) -> String:
	return s.capitalize().replace("_", " ")
