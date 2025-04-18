class_name StarwayScreen extends MarginContainer

const TAB_DATA_ID: String = "starway"

@export var substance_controller: SubstanceController

var particle_id: String = "resource_acquired_particle"  # "enemy_damage_particle"
var singularity_color: Color = ColorSwatches.YELLOW
var heart_color: Color = ColorSwatches.BLUE

@onready var progress_bar_margin_container: BasicProgressBar = %ProgressBarMarginContainer
@onready var top_label: Label = %TopLabel

@onready var label_effect_queue_1: LabelEffectQueue = %LabelEffectQueue1
@onready var label_effect_queue_2: LabelEffectQueue = %LabelEffectQueue2
#
@onready var spawner_buffer_particles: Node2D = %SpawnerBufferParticles
@onready var spawner_buffer_substance: SpawnerBuffer = %SpawnerBufferSubstance
@onready var spawner_buffer_singularity: SpawnerBuffer = %SpawnerBufferSingularity
@onready var resource_queue_timer: Timer = %ResourceQueueTimer

###############
## overrides ##
###############


func _process(_delta: float) -> void:
	if is_visible_in_tree():
		_set_top_label()

	if Game.USE_TWEENS_OVER_PARTICLES:
		spawner_buffer_particles.position.x = self.get_rect().size.x / 2
		spawner_buffer_particles.position.y = self.get_rect().size.y / 2


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		_propagate_theme_to_virtual_children()


func _ready() -> void:
	_connect_signals()
	_reload()


#############
## helpers ##
#############


func _reload() -> void:
	_initialize()
	_load_from_save_file()


func _initialize() -> void:
	_set_infinity_progress()
	_propagate_theme_to_virtual_children()
	if not Game.USE_TWEENS_OVER_PARTICLES:
		label_effect_queue_1.set_particle(particle_id)
		label_effect_queue_2.set_particle(particle_id)


func _load_from_save_file() -> void:
	top_label.visible = SaveFile.get_prestige_count() > 0


func _set_top_label() -> void:
	if top_label.visible:
		var current: String = SaveFile.current_prestige_time()
		var best: String = SaveFile.best_prestige_time()
		var l0: String = Locale.get_ui_label("current")
		var l1: String = Locale.get_ui_label("best")
		top_label.text = "{l0}: {0} | {l1}: {1}".format(
			{"0": current, "1": best, "l0": l0, "l1": l1}
		)

		var has_death: bool = SaveFile.substances.get("death", 0) > 0
		if has_death:
			var elapsed: int = int(substance_controller.death_timer.time_left)
			var death: String = DateTimeUtils.format_seconds(elapsed, false)
			var l2: String = Locale.get_ui_label("death")
			top_label.text += " | {l2}: {0}".format({"0": death, "l2": l2})


func _set_infinity_progress() -> void:
	var infinity_progress: Dictionary = PrestigeController.get_infinity_progress()
	var max_infinity_count: int = infinity_progress["max_infinity_count"]
	var max_amount: int = infinity_progress["max_amount"]
	var max_resource_id: String = infinity_progress["max_resource_id"]
	var max_resource_name: String = infinity_progress["max_resource_name"]
	var infinity_count: int = infinity_progress["infinity_count"]

	if !StringUtils.is_not_empty(max_resource_id):
		progress_bar_margin_container.visible = false
		return
	progress_bar_margin_container.visible = true

	var progress: float
	var progress_label: String
	if infinity_count >= max_infinity_count:
		progress_label = Locale.get_ui_label("max")
		progress = 1.0
	elif infinity_count <= 0:
		progress = log(max_amount) / log(Limits.GLOBAL_MAX_AMOUNT)
		progress_label = Locale.get_ui_label("infinity_progress_1").format(
			{"0": "%2.2f" % (progress * 100.0), "1": max_resource_name}
		)
	else:
		progress = float(infinity_count) / float(max_infinity_count)
		progress_label = Locale.get_ui_label("infinity_progress_2").format(
			{"1": infinity_count, "2": max_infinity_count}
		)

	progress_bar_margin_container.set_display(progress, progress_label, ColorSwatches.BLUE)


func _update_pivot() -> void:
	self.set_pivot_offset(Vector2(self.size.x / 2, self.size.y / 2))
	if not Game.USE_TWEENS_OVER_PARTICLES:
		label_effect_queue_1.position.x = (self.get_rect().size.x / 2)
		label_effect_queue_1.position.y = (self.get_rect().size.y / 2)
		label_effect_queue_2.position.x = (self.get_rect().size.x / 2)
		label_effect_queue_2.position.y = (self.get_rect().size.y / 2)


func _propagate_theme_to_virtual_children() -> void:
	if not Game.USE_TWEENS_OVER_PARTICLES:
		var inherited_theme: Resource = NodeUtils.get_inherited_theme(self)
		if label_effect_queue_1 != null:
			label_effect_queue_1.set_theme(inherited_theme)
			label_effect_queue_1.set_color_theme_override(heart_color)
		if label_effect_queue_2 != null:
			label_effect_queue_2.set_theme(inherited_theme)
			label_effect_queue_2.set_color_theme_override(singularity_color)


#############
## signals ##
#############


func _connect_signals() -> void:
	self.resized.connect(_on_resized)
	SignalBus.tab_changed.connect(_on_tab_changed)
	SignalBus.resource_updated.connect(_on_resource_updated)
	SignalBus.substance_updated.connect(_on_substance_updated)
	SignalBus.display_language_updated.connect(_on_display_language_updated)


func _on_resized() -> void:
	_update_pivot()


func _on_tab_changed(tab_data: TabData) -> void:
	if tab_data.id == TAB_DATA_ID:
		visible = true
	else:
		visible = false


func _on_resource_updated(id: String, _total: int, amount: int, source_id: String) -> void:
	_set_infinity_progress()
	if is_visible_in_tree():
		if id == "singularity" and source_id == "SubstanceController":
			var singularity: ResourceGenerator = Resources.resource_generators[id]
			if Game.USE_TWEENS_OVER_PARTICLES:
				var name_text: String = singularity.get_display_name()
				spawner_buffer_singularity.process([amount, name_text])
			else:
				var text: String = singularity.get_display_increment(amount)
				label_effect_queue_2.add_task(text)


func _on_substance_updated(id: String, _total_amount: int, source_id: String) -> void:
	if is_visible_in_tree():
		if id == "heart" and source_id == "SubstanceController":
			var display_name: String = Locale.get_ui_label("heart")
			if Game.USE_TWEENS_OVER_PARTICLES:
				var substance_data: SubstanceData = Resources.substance_datas.get(id, null)
				var name_text: String = substance_data.get_display_name()
				spawner_buffer_substance.process([1, name_text])
			else:
				var text: String = ResourceGenerator.get_display_increment_of(1, display_name)
				label_effect_queue_1.add_task(text)


func _on_display_language_updated() -> void:
	_reload()
