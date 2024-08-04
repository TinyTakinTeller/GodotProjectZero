class_name ManagerButton extends MarginContainer

## effect params
var label_color: Color = ColorSwatches.GREEN
var particle_id: String = "resource_generated_particle"

var _worker_role: WorkerRole

@onready var del_button: Button = %DelButton
@onready var add_button: Button = %AddButton
@onready var info_label: Label = %InfoLabel
@onready var amount_label: Label = %AmountLabel
@onready var new_unlock_tween: Node = %NewUnlockTween
@onready var label_effect_queue: LabelEffectQueue = %LabelEffectQueue

###############
## overrides ##
###############


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		_propagate_theme_to_virtual_children()


func _ready() -> void:
	_display_defaults()
	_connect_signals()
	_toggle_mode()


###########
## setup ##
###########


func get_id() -> String:
	if _worker_role == null:
		return ""
	return _worker_role.id


func get_count() -> int:
	return SaveFile.workers.get(get_id(), 0)


func set_worker_role(worker_role: WorkerRole) -> void:
	_worker_role = worker_role


func display_worker_role(amount: int) -> void:
	visible = true
	_set_info()
	_set_amount(amount)


###############
## animation ##
###############


func start_unlock_animation() -> void:
	new_unlock_tween.loop = true
	new_unlock_tween.play_animation()


func stop_unlock_animation() -> void:
	new_unlock_tween.loop = false


func _emit_label_effect_particle(resource_id: String, amount: int) -> void:
	var resource_generator: ResourceGenerator = Resources.resource_generators[resource_id]
	var text: String = resource_generator.get_display_increment(amount)
	label_effect_queue.add_task(text)


#############
## helpers ##
#############


func _toggle_mode(mode: int = -1) -> void:
	if mode == -1:
		mode = SaveFile.settings.get("manager_mode", 0)

	if mode == 0:
		del_button.text = "-"
		add_button.text = "+"
	elif mode == 1:
		del_button.text = "<"
		add_button.text = ">"


func _display_defaults() -> void:
	visible = false
	_update_pivot()
	_propagate_theme_to_virtual_children()
	label_effect_queue.set_particle(particle_id)


func _propagate_theme_to_virtual_children() -> void:
	var inherited_theme: Resource = NodeUtils.get_inherited_theme(self)
	if label_effect_queue != null:
		label_effect_queue.set_theme(inherited_theme)
		label_effect_queue.set_color_theme_override(label_color)


func _set_info() -> void:
	info_label.text = _worker_role.get_title()
	if _worker_role.default:
		del_button.disabled = true
		add_button.disabled = true


func _set_amount(amount: int) -> void:
	var amount_string: String = NumberUtils.format_number_scientific(amount)
	amount_label.text = "{amount}".format({"amount": amount_string})


func _update_pivot() -> void:
	self.set_pivot_offset(Vector2(self.size.x / 2, self.size.y / 2))
	label_effect_queue.position.x = self.get_rect().size.x / 2
	label_effect_queue.position.y = self.get_rect().size.y / 2


func _clear_hints() -> void:
	amount_label.modulate = Color.WHITE
	del_button.modulate = Color.WHITE
	add_button.modulate = Color.WHITE


func _update_del_hint(inefficient: bool) -> void:
	if inefficient:
		amount_label.modulate = Color(0.878, 0, 0.392)
		del_button.modulate = Color(0.878, 0, 0.392)
	else:
		del_button.modulate = Color.WHITE


func _update_add_hint(inefficient: bool) -> void:
	if inefficient:
		amount_label.modulate = Color(0.878, 0, 0.392)
		add_button.modulate = Color(0.878, 0, 0.392)
	else:
		add_button.modulate = Color.WHITE


##############
## handlers ##
##############


func _handle_worker_efficiency_updated(efficiencies: Dictionary, generate: bool) -> void:
	if _worker_role == null:
		return
	var produce_ids: Array = _worker_role.get_produce().keys()
	var resources: Dictionary = efficiencies["resources"]
	var workers: Dictionary = efficiencies["workers"]

	for resource_id: String in produce_ids:
		var amount: int = resources.get(resource_id, 0) + workers.get(resource_id, 0)
		if amount > 0 and generate:
			_emit_label_effect_particle(resource_id, amount)


#############
## signals ##
#############


func _connect_signals() -> void:
	self.resized.connect(_on_resized)
	self.mouse_entered.connect(_on_mouse_entered.bind(self))
	del_button.mouse_entered.connect(_on_mouse_entered.bind(del_button))
	add_button.mouse_entered.connect(_on_mouse_entered.bind(add_button))
	self.mouse_exited.connect(_on_mouse_exited.bind(self))
	del_button.mouse_exited.connect(_on_mouse_exited.bind(del_button))
	add_button.mouse_exited.connect(_on_mouse_exited.bind(add_button))
	add_button.button_up.connect(_on_add_button_up)
	del_button.button_up.connect(_on_del_button_up)
	add_button.button_down.connect(_on_add_button_down)
	del_button.button_down.connect(_on_del_button_down)
	SignalBus.worker_updated.connect(_on_worker_updated)
	SignalBus.worker_efficiency_updated.connect(_on_worker_efficiency_updated)
	SignalBus.worker_allocated.connect(_on_worker_allocated)
	SignalBus.resource_storage_hover.connect(_on_resource_storage_hover)
	SignalBus.resource_storage_unhover.connect(_on_resource_storage_unhover)
	SignalBus.toggle_manager_mode.connect(_on_toggle_manager_mode)


func _on_resized() -> void:
	_update_pivot()


func _on_mouse_entered(node: Node) -> void:
	SignalBus.manager_button_hover.emit(_worker_role, node)
	stop_unlock_animation()


func _on_mouse_exited(node: Node) -> void:
	SignalBus.manager_button_unhover.emit(_worker_role, node)


## calling _on_mouse_entered() here because mobile users don't have mouse_entered signal
func _on_add_button_up() -> void:
	_on_mouse_entered(null)

	var mode: int = SaveFile.settings.get("manager_mode", 0)
	if mode == 0:
		SignalBus.manager_button_add.emit(_worker_role)
	elif mode == 1:
		SignalBus.manager_button_smart_add.emit(_worker_role)

	add_button.release_focus()


## calling _on_mouse_entered() here because mobile users don't have mouse_entered signal
func _on_del_button_up() -> void:
	_on_mouse_entered(null)

	var mode: int = SaveFile.settings.get("manager_mode", 0)
	if mode == 0:
		SignalBus.manager_button_del.emit(_worker_role)
	elif mode == 1:
		SignalBus.manager_button_smart_del.emit(_worker_role)

	del_button.release_focus()


func _on_add_button_down() -> void:
	pass


func _on_del_button_down() -> void:
	pass


func _on_worker_updated(id: String, total: int, _amount: int) -> void:
	if get_id() == id:
		_set_amount(total)


func _on_worker_efficiency_updated(efficiencies: Dictionary, generate: bool) -> void:
	if !is_visible_in_tree():
		return
	_handle_worker_efficiency_updated(efficiencies, generate)


func _on_worker_allocated(id: String, amount: int, _source_id: String) -> void:
	if get_id() != id:
		return
	if amount != 0:
		Audio.play_sfx_id("manager_button_allocated", 0.0)
	else:
		Audio.play_sfx_id("manager_button_zero", 0.0)


func _on_worker_inefficient(
	worker_role_id: String, _efficiency: int, _worker_role_count: int
) -> void:
	if get_id() != worker_role_id:
		return
	modulate.g = 0
	modulate.b = 0


func _on_worker_efficient(worker_role_id: String) -> void:
	if get_id() != worker_role_id:
		return
	modulate.g = 1
	modulate.b = 1


func _on_resource_storage_hover(resource: ResourceGenerator) -> void:
	if _worker_role == null:
		return
	var id: String = resource.id

	if _worker_role.get_consume().has(id) or _worker_role.get_worker_consume().has(id):
		info_label.modulate = ColorSwatches.RED
	elif _worker_role.get_produce().has(id):
		info_label.modulate = ColorSwatches.GREEN
	else:
		info_label.modulate = Color.WHITE


func _on_resource_storage_unhover(_resource: ResourceGenerator) -> void:
	info_label.modulate = Color.WHITE


func _on_toggle_manager_mode(mode: int) -> void:
	_toggle_mode(mode)


############
## static ##
############


static func before_than(a: ManagerButton, b: ManagerButton) -> bool:
	var sort_a: WorkerRole = Resources.worker_roles.get(a.get_id(), null)
	var sort_b: WorkerRole = Resources.worker_roles.get(b.get_id(), null)
	if sort_a == null:
		return true
	if sort_b == null:
		return false
	return sort_a.sort_value < sort_b.sort_value
