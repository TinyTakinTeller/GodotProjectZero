extends MarginContainer
class_name ManagerButton

@onready var del_button: Button = %DelButton
@onready var add_button: Button = %AddButton
@onready var amount_label: Label = %AmountLabel
@onready var info_label: Label = %InfoLabel
@onready var new_unlock_tween: Node = %NewUnlockTween
@onready var label_effect_queue: Node2D = %LabelEffectQueue

@export var _worker_role: WorkerRole


func _propagate_theme_to_children() -> void:
	var inherited_theme: Resource = NodeUtils.get_inherited_theme(self)
	if label_effect_queue != null:
		label_effect_queue.set_theme(inherited_theme)


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		_propagate_theme_to_children()


func _ready() -> void:
	visible = false
	_propagate_theme_to_children()
	add_button.button_up.connect(_on_add_button_up)
	del_button.button_up.connect(_on_del_button_up)
	self.mouse_entered.connect(_on_mouse_entered)
	SignalBus.worker_updated.connect(_on_worker_updated)
	SignalBus.worker_efficiency_updated.connect(_on_worker_efficiency_updated)


func get_id() -> String:
	return _worker_role.id


func display_worker_role(amount: int) -> void:
	info_label.text = _worker_role.get_title()
	self.set_pivot_offset(Vector2(self.size.x / 2, self.size.y / 2))
	_set_amount(amount)
	visible = true
	if _worker_role.default:
		del_button.disabled = true
		add_button.disabled = true
	label_effect_queue.position.x += self.get_rect().size.x
	label_effect_queue.position.y += self.get_rect().size.y / 2


func set_worker_role(worker_role: WorkerRole) -> void:
	_worker_role = worker_role


func start_unlock_animation() -> void:
	new_unlock_tween.loop = true
	new_unlock_tween.play_animation()


func stop_unlock_animation() -> void:
	new_unlock_tween.loop = false


func _set_amount(amount: int) -> void:
	amount_label.text = "{amount}".format({"amount": amount})


func _on_add_button_up() -> void:
	SignalBus.manager_button_add.emit(_worker_role)
	add_button.release_focus()


func _on_del_button_up() -> void:
	SignalBus.manager_button_del.emit(_worker_role)
	del_button.release_focus()


func _on_mouse_entered() -> void:
	SignalBus.manager_button_hover.emit(_worker_role)
	stop_unlock_animation()


func _on_worker_updated(id: String, total: int, _amount: int) -> void:
	if get_id() == id:
		_set_amount(total)


func _on_worker_efficiency_updated(efficiencies: Dictionary) -> void:
	if !is_visible_in_tree():
		return
	for resource_id: String in efficiencies:
		if _worker_role.produce.has(resource_id):
			var amount: int = efficiencies[resource_id]
			if amount <= 0:
				continue
			var resource_generator: ResourceGenerator = Resources.resource_generators[resource_id]
			var text: String = resource_generator.get_display_increment(amount)
			label_effect_queue.add_task(text)


static func before_than(a: ManagerButton, b: ManagerButton) -> bool:
	var sort_a: WorkerRole = Resources.worker_roles.get(a.get_id(), null)
	var sort_b: WorkerRole = Resources.worker_roles.get(b.get_id(), null)
	if sort_a == null:
		return true
	if sort_b == null:
		return false
	return sort_a.sort_value < sort_b.sort_value
