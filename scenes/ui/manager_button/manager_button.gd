extends MarginContainer
class_name ManagerButton

@onready var del_button: Button = %DelButton
@onready var add_button: Button = %AddButton
@onready var amount_label: Label = %AmountLabel
@onready var info_label: Label = %InfoLabel
@onready var new_unlock_tween: Node = %NewUnlockTween

@export var _worker_role: WorkerRole


func _ready() -> void:
	visible = false
	add_button.button_up.connect(_on_add_button_up)
	del_button.button_up.connect(_on_del_button_up)
	self.mouse_entered.connect(_on_mouse_entered)
	SignalBus.worker_updated.connect(_on_worker_updated)


func _setup() -> void:
	info_label.text = _worker_role.get_title()
	self.set_pivot_offset(Vector2(self.size.x / 2, self.size.y / 2))
	visible = true


func set_worker_role(worker_role: WorkerRole, amount: int) -> void:
	_worker_role = worker_role
	_set_amount(amount)
	_setup()


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
	if _worker_role.id == id:
		_set_amount(total)
