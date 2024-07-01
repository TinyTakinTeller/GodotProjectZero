extends MarginContainer

const TAB_DATA_ID: String = "offline"

var offlline_tab_data: TabData = Resources.tab_datas[TAB_DATA_ID]

@onready var label1: Label = %Label1
@onready var label2: Label = %Label2
@onready var label_head: Label = %LabelHead
@onready var margin_container_1: MarginContainer = %MarginContainer1
@onready var margin_container_2: MarginContainer = %MarginContainer2

###############
## overrides ##
###############


func _ready() -> void:
	_initialize()
	_load_from_save_file()
	_connect_signals()


#############
## helpers ##
#############


func _initialize() -> void:
	pass


func _load_from_save_file() -> void:
	pass


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.tab_changed.connect(_on_tab_changed)
	SignalBus.offline_progress_processed.connect(_on_offline_progress_processed)


func _on_tab_changed(tab_data: TabData) -> void:
	if tab_data.id == TAB_DATA_ID:
		visible = true
	else:
		visible = false


func _on_offline_progress_processed(
	seconds_delta: int, worker_progress: Dictionary, enemy_progress: Dictionary, factor: float
) -> void:
	if worker_progress.is_empty() or enemy_progress.is_empty():
		return

	var generated: Dictionary = worker_progress["generated"]
	var decreasing_ids: Array = worker_progress["decreasing_ids"]
	# var damage: int = enemy_progress["damage"]
	# var overkill_factor: float = enemy_progress["overkill_factor"]
	var workers_are_happy: bool = decreasing_ids.is_empty()
	var time: String = DateTimeUtils.format_seconds(seconds_delta)

	if !workers_are_happy:
		label_head.text = (
			Locale.get_ui_label("offline_1").format({"0": time})
			+ Locale.get_ui_label("offline_2")
			+ Locale.get_ui_label("offline_3")
		)

		var decreasing_infos: Array = []
		for resource_id: String in decreasing_ids:
			var resource: ResourceGenerator = Resources.resource_generators[resource_id]
			decreasing_infos.append(resource.get_display_name())

		label1.text = ", ".join(decreasing_infos) + "."
		label1.modulate = ColorSwatches.RED
		margin_container_1.visible = true
		margin_container_2.visible = false

	else:
		if generated.is_empty():
			return

		label_head.text = (
			Locale.get_ui_label("offline_1").format({"0": time})
			+ Locale.get_ui_label("offline_4").format({"0": int(factor * 100)})
		)

		var generated_size: int = generated.size()
		var split_index: int = (generated_size + 1) / 2
		var index: int = 0
		var generated_info1: String = ""
		var generated_info2: String = ""
		for resource_id: String in generated:
			var resource: ResourceGenerator = Resources.resource_generators[resource_id]
			var generated_amount: String = NumberUtils.format_number_scientific(
				generated[resource_id]
			)

			var generated_info: String = "+{amount} {name} \n".format(
				{"amount": generated_amount, "name": resource.get_display_name()}
			)
			if index < split_index:
				generated_info1 += generated_info
			else:
				generated_info2 += generated_info
			index += 1

		label1.text = generated_info1
		label2.text = generated_info2
		label1.modulate = ColorSwatches.GREEN
		label2.modulate = ColorSwatches.GREEN
		margin_container_1.visible = true
		margin_container_2.visible = true

	SignalBus.tab_clicked.emit(offlline_tab_data)
