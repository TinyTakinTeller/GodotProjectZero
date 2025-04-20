class_name DefaultLocaleConfigStorage

const SECTION: String = "Defaults"
const KEY: String = "DefaultLocale"
const DEFAULT: String = ""


static func get_value() -> String:
	return ConfigStorage.get_config(SECTION, KEY, DEFAULT)


static func set_value(value: String) -> void:
	ConfigStorage.set_config(SECTION, KEY, value)
