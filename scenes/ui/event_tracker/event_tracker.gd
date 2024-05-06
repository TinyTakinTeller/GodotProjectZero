extends MarginContainer

@onready var event_v_box_container: VBoxContainer = %EventVBoxContainer
@onready var scroll_container: ScrollContainer = %ScrollContainer

@export var event_item_scene: PackedScene
@export var PAGE_SIZE: int = 20

var _total_lines: int = 0


func _ready() -> void:
	_load_from_save_file()
	SignalBus.event_saved.connect(_on_event_saved)
	_disable_scrollbars()


func _load_from_save_file() -> void:
	_clear_items()
	var next_index: int = SaveFile.event_log.size()
	for index: int in range(min(PAGE_SIZE, next_index)):
		var event_log_index: int = index + 1
		var event_log: Dictionary = SaveFile.event_log[str(event_log_index)]
		var event_data_id: String = event_log["event_data"]
		var event_data: EventData = Resources.event_datas[event_data_id]
		var vals: Array = event_log["vals"]
		_add_event(event_data, vals, event_log_index)


func _add_event(event_data: EventData, vals: Array, index: int) -> void:
	var event_item: EventTrackerItem = _add_item()
	event_item.set_content(event_data, vals, index)
	_total_lines += 1
	while _total_lines > PAGE_SIZE:
		NodeUtils.remove_oldest(event_v_box_container)
		_total_lines -= 1


func _add_item() -> EventTrackerItem:
	var event_item: EventTrackerItem = event_item_scene.instantiate() as EventTrackerItem
	NodeUtils.add_child_front(event_item, event_v_box_container)
	return event_item


func _clear_items() -> void:
	_total_lines = 0
	NodeUtils.clear_children(event_v_box_container)


func _on_event_saved(event_data: EventData, vals: Array, index: int) -> void:
	_add_event(event_data, vals, index)


func _disable_scrollbars() -> void:
	var invisible_scrollbar_theme: Theme = Theme.new()
	var empty_stylebox: StyleBoxEmpty = StyleBoxEmpty.new()
	invisible_scrollbar_theme.set_stylebox("scroll", "VScrollBar", empty_stylebox)
	invisible_scrollbar_theme.set_stylebox("scroll", "HScrollBar", empty_stylebox)
	scroll_container.get_h_scroll_bar().theme = invisible_scrollbar_theme
	scroll_container.get_v_scroll_bar().theme = invisible_scrollbar_theme
