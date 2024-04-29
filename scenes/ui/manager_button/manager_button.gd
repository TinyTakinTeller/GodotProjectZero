extends MarginContainer
class_name ManagerButton

@onready var del_button: Button = %DelButton
@onready var add_button: Button = %AddButton
@onready var amount_label: Label = %AmountLabel
@onready var info_label: Label = %InfoLabel

@export var _worker_role: WorkerRole


func _ready() -> void:
	visible = false
	add_button.button_up.connect(_on_add_button_up)
	del_button.button_up.connect(_on_del_button_up)
	self.mouse_entered.connect(_on_mouse_entered)
	SignalBus.worker_updated.connect(_on_worker_updated)


func _setup() -> void:
	_set_amount(0)
	info_label.text = _worker_role.get_title()
	visible = true


func set_worker_role(worker_role: WorkerRole) -> void:
	_worker_role = worker_role
	_setup()


func _set_amount(amount: int) -> void:
	amount_label.text = "{amount}".format({"amount": amount})


func _on_add_button_up() -> void:
	SignalBus.manager_button_add.emit(_worker_role)


func _on_del_button_up() -> void:
	SignalBus.manager_button_del.emit(_worker_role)


func _on_mouse_entered() -> void:
	SignalBus.manager_button_hover.emit(_worker_role)


func _on_worker_updated(id: String, total: int, _amount: int) -> void:
	if _worker_role.id == id:
		_set_amount(total)
