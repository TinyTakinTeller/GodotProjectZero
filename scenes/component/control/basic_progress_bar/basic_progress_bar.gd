class_name BasicProgressBar
extends MarginContainer

@onready var progress_bar: ProgressBar = %ProgressBar
@onready var progress_bar_label: Label = %ProgressBarLabel
@onready var title_margin_container: MarginContainer = %TitleMarginContainer


func set_display(percent: float, text: String = "", color: Color = Color.WHITE) -> void:
	progress_bar.value = percent
	progress_bar_label.text = text
	title_margin_container.visible = StringUtils.is_not_empty(text)
	progress_bar.modulate = color
	progress_bar_label.modulate = color
