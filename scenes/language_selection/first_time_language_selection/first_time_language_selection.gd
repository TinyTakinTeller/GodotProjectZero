extends Control


func _ready() -> void:
	var locale: String = DefaultLocaleConfigStorage.get_value()
	if locale != DefaultLocaleConfigStorage.DEFAULT:
		self.visible = false
		self.queue_free.call_deferred()
		return

	self.visible = true
	get_tree().paused = true

	var buttons: Array[LanguageButton] = [
		%LanguageButtonFr,
		%LanguageButtonPl,
		%LanguageButtonPt,
		%LanguageButtonZh,
		%LanguageButtonEn
	]
	for button: LanguageButton in buttons:
		button.clicked.connect(_on_button_clicked)


func _on_button_clicked(locale: String) -> void:
	DefaultLocaleConfigStorage.set_value(locale)
	Scene.change_language_to(locale)
	self.visible = false
	get_tree().paused = false
