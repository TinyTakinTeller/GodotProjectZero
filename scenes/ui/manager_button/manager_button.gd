extends MarginContainer
class_name ManagerButton

@onready var del_button: Button = %DelButton
@onready var add_button: Button = %AddButton
@onready var info_label: Label = %InfoLabel
@onready var amount_label: Label = %AmountLabel
@onready var new_unlock_tween: Node = %NewUnlockTween
@onready var label_effect_queue: LabelEffectQueue = %LabelEffectQueue

## effect params
var label_color: Color = Color(0.392, 0.878, 0, 1)
var particle_id: String = "resource_generated_particle"

var _worker_role: WorkerRole

###############
## overrides ##
###############


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		_propagate_theme_to_virtual_children()


func _ready() -> void:
	_display_defaults()
	_connect_signals()


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
	self.mouse_entered.connect(_on_mouse_entered)
	del_button.mouse_entered.connect(_on_mouse_entered)
	add_button.mouse_entered.connect(_on_mouse_entered)
	add_button.button_up.connect(_on_add_button_up)
	del_button.button_up.connect(_on_del_button_up)
	SignalBus.worker_updated.connect(_on_worker_updated)
	SignalBus.worker_efficiency_updated.connect(_on_worker_efficiency_updated)


func _on_resized() -> void:
	_update_pivot()


func _on_mouse_entered() -> void:
	SignalBus.manager_button_hover.emit(_worker_role)
	stop_unlock_animation()


## calling _on_mouse_entered() here because mobile users don't have mouse_entered signal
func _on_add_button_up() -> void:
	_on_mouse_entered()
	SignalBus.manager_button_add.emit(_worker_role)
	add_button.release_focus()


## calling _on_mouse_entered() here because mobile users don't have mouse_entered signal
func _on_del_button_up() -> void:
	_on_mouse_entered()
	SignalBus.manager_button_del.emit(_worker_role)
	del_button.release_focus()


func _on_worker_updated(id: String, total: int, _amount: int) -> void:
	if get_id() == id:
		_set_amount(total)


func _on_worker_efficiency_updated(efficiencies: Dictionary, generate: bool) -> void:
	if !is_visible_in_tree():
		return
	_handle_worker_efficiency_updated(efficiencies, generate)


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
