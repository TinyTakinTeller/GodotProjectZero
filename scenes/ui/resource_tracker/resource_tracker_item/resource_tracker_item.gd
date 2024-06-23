class_name ResourceTrackerItem
extends MarginContainer

var _resource_generator: ResourceGenerator
var _hovering: bool = false

@onready var amount_label: Label = %AmountLabel
@onready var income_label: Label = %IncomeLabel
@onready var modulate_red_simple_tween: SimpleTween = %ModulateRedSimpleTween

###############
## overrides ##
###############


func _ready() -> void:
	_initialize()
	_connect_signals()


###########
## setup ##
###########


func get_id() -> String:
	if _resource_generator == null:
		return ""
	return _resource_generator.id


func set_resource(resource_generator: ResourceGenerator) -> void:
	_resource_generator = resource_generator


###############
## animation ##
###############


func play_modulate_red_simple_tween_animation() -> void:
	modulate_red_simple_tween.play_animation()


#############
## helpers ##
#############


func _initialize() -> void:
	amount_label.text = ""
	income_label.text = ""


func get_default_color() -> Color:
	if _resource_generator == null:
		return Color.WHITE
	var amount: int = SaveFile.resources.get(get_id(), 0)
	if amount >= Limits.GLOBAL_MAX_AMOUNT:
		return ColorSwatches.BLUE
	if _resource_generator.is_colored():
		return _resource_generator.get_color()
	return Color.WHITE


func display_resource(amount: int = 0) -> void:
	var id: String = get_id()
	if Game.WORKER_ROLE_RESOURCE.has(id):
		amount = SaveFile.workers.get(id, 0)

	var resource_name: String = _resource_generator.get_display_name()
	var amount_string: String = NumberUtils.format_number_scientific(amount)
	amount_label.text = "{name}: {amount}".format({"name": resource_name, "amount": amount_string})

	if !_hovering:
		amount_label.modulate = get_default_color()


func _set_passive(amount: int) -> void:
	var amount_string: String = NumberUtils.format_number_scientific(amount)
	if amount > 0:
		income_label.text = "+{amount}".format({"amount": amount_string})
		income_label.modulate = ColorSwatches.GREEN
	elif amount < 0:
		income_label.text = "{amount}".format({"amount": amount_string})
		income_label.modulate = ColorSwatches.RED
	else:
		income_label.text = ""


##############
## handlers ##
##############


func _handle_on_worker_efficiency_updated(efficiencies: Dictionary) -> void:
	var id: String = get_id()
	var delta: int = efficiencies["resources"].get(id, 0) + efficiencies["workers"].get(id, 0)
	var total_eff: int = efficiencies["total_efficiency"].get(id, 0)
	var amount: int = SaveFile.resources.get(id, 0)

	_set_passive(delta)
	if total_eff < 0 and amount < (total_eff * -1):
		income_label.text = "NA"
		income_label.modulate = ColorSwatches.RED


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.worker_efficiency_updated.connect(_on_worker_efficiency_updated)
	SignalBus.worker_updated.connect(_on_worker_updated)
	self.mouse_entered.connect(_on_mouse_entered)
	self.mouse_exited.connect(_on_mouse_exited)
	SignalBus.manager_button_hover.connect(_on_manager_button_hover)
	SignalBus.manager_button_unhover.connect(_on_manager_button_unhover)


func _on_worker_efficiency_updated(efficiencies: Dictionary, _generated: bool) -> void:
	_handle_on_worker_efficiency_updated(efficiencies)


func _on_worker_updated(_id: String, _total: int, _amount: int) -> void:
	var id: String = get_id()
	if Game.WORKER_ROLE_RESOURCE.has(id):
		display_resource()


func _on_mouse_entered() -> void:
	SignalBus.resource_storage_hover.emit(_resource_generator)
	if Game.params["resource_storage_info"]:
		SignalBus.info_hover.emit(
			_resource_generator.get_display_name(),
			_resource_generator.get_display_info(amount_label.text, income_label.text)
		)


func _on_mouse_exited() -> void:
	SignalBus.resource_storage_unhover.emit(_resource_generator)


func _on_manager_button_hover(worker_role: WorkerRole, node: Node) -> void:
	if !is_instance_of(node, Button):
		return
	_hovering = true
	var id: String = get_id()
	if worker_role.get_consume().has(id) or worker_role.get_worker_consume().has(id):
		amount_label.modulate = ColorSwatches.RED
	elif worker_role.get_produce().has(id):
		amount_label.modulate = ColorSwatches.GREEN
	else:
		amount_label.modulate = get_default_color()


func _on_manager_button_unhover(_worker_role: WorkerRole, node: Node) -> void:
	if !is_instance_of(node, Button):
		return
	_hovering = false
	amount_label.modulate = get_default_color()


############
## export ##
############


func _modulate_red_simple_tween_method(animation_percent: float) -> void:
	var c: Color = get_default_color()
	var offset: float = 1 - animation_percent
	amount_label.modulate = Color(c.r, c.g - offset, c.b - offset)


############
## static ##
############


static func before_than(a: ResourceTrackerItem, b: ResourceTrackerItem) -> bool:
	var sort_a: ResourceGenerator = Resources.resource_generators.get(a.get_id(), null)
	var sort_b: ResourceGenerator = Resources.resource_generators.get(b.get_id(), null)
	if sort_a == null:
		return true
	if sort_b == null:
		return false
	return sort_a.sort_value < sort_b.sort_value
