extends MarginContainer
class_name EnemyProgressBar

@onready var progress_bar_left: ProgressBar = %ProgressBarLeft
@onready var progress_bar_right: ProgressBar = %ProgressBarRight
@onready var progress_bar_label: Label = %ProgressBarLabel
@onready var progress_bar_margin_container: MarginContainer = %ProgressBarMarginContainer


func set_display(percent: float, health: int) -> void:
	progress_bar_left.value = percent
	progress_bar_right.value = percent
	progress_bar_label.text = NumberUtils.format_number(health)
