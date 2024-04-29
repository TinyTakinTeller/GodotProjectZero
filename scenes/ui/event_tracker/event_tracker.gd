extends MarginContainer

@onready var event_v_box_container: VBoxContainer = %EventVBoxContainer

@export var event_item_scene: PackedScene
@export var PAGE_SIZE: int = 20

var _total_lines: int = 0


func _ready() -> void:
	_clear_items()
	SignalBus.event_saved.connect(_on_event_saved)


## add line(s) and keep only {PAGE_SIZE} newest lines by deleting oldest line(s)
func add_event(content: String, index: int) -> void:
	var event_item: EventTrackerItem = _add_item()
	event_item.set_content(content, index)
	_total_lines += 1
	while _total_lines > PAGE_SIZE:
		NodeUtils.remove_oldest(event_v_box_container)
		_total_lines -= 1


func _add_item() -> EventTrackerItem:
	var event_item: EventTrackerItem = event_item_scene.instantiate() as EventTrackerItem
	event_v_box_container.add_child(event_item)
	event_v_box_container.move_child(event_item, 0)
	return event_item


func _clear_items() -> void:
	_total_lines = 0
	NodeUtils.clear_children(event_v_box_container)


func _on_event_saved(content: String, index: int) -> void:
	add_event(content, index)
