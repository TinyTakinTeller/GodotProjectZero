class_name DictionaryUtils


static func merge_sum_int(a: Dictionary, b: Dictionary) -> void:
	for key: String in b:
		a[key] = a.get(key, 0) + b.get(key, 0)
