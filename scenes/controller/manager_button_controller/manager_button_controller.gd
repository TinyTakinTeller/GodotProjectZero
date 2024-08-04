extends Node

@export var worker_controller: WorkerController

var produced_by_cache: Dictionary = {}
var requirements_map: Dictionary = {}

###############
## overrides ##
###############


func _ready() -> void:
	_connect_signals()
	_initialize()


#############
## helpers ##
#############


func _initialize() -> void:
	for worker_role_id: String in Resources.worker_roles:
		var worker_role: WorkerRole = Resources.worker_roles[worker_role_id]
		var reqs: Dictionary = _get_requirements(worker_role)
		requirements_map[worker_role_id] = reqs
		if Game.PARAMS["debug_logs"]:
			prints(worker_role_id, " requires ", DictionaryUtils.sum(reqs), " ", reqs)


func _get_requirements(worker_role: WorkerRole, reqs: Dictionary = {}, mult: int = 1) -> Dictionary:
	var costs: Dictionary = worker_role.get_consume()
	for cost_id: String in costs:
		var cost_amount: int = costs[cost_id] * mult
		var cost_resource: ResourceGenerator = Resources.resource_generators[cost_id]
		var req_id: String = _get_produced_by(cost_resource)
		if StringUtils.is_not_empty(req_id):
			reqs[req_id] = reqs.get(req_id, 0) + cost_amount
			var next_worker_role: WorkerRole = Resources.worker_roles.get(req_id)
			_get_requirements(next_worker_role, reqs, cost_amount)
	return reqs


func _get_produced_by(resource_generator: ResourceGenerator) -> String:
	var id: String = resource_generator.id
	var cached_result: String = produced_by_cache.get(id, "null")
	if cached_result != "null":
		return cached_result

	var produced_by: Array[String] = []
	for worker_role_id: String in Resources.worker_roles:
		var worker_role: WorkerRole = Resources.worker_roles[worker_role_id]
		var produces: Dictionary = worker_role.get_produce()
		if produces.has(id):
			produced_by.append(worker_role_id)

	if produced_by.is_empty():
		produced_by_cache[id] = ""
		return ""
	if produced_by.size() > 1:
		push_warning(
			"resource {0} is produced by multiple worker roles {1}".format(
				{"0": id, "1": produced_by}
			)
		)
	produced_by_cache[id] = produced_by[0]
	return produced_by[0]


## minimum of: worker amount (id) and settings scale amount
func _get_settings_population_scale(id: String) -> int:
	var workers: int = SaveFile.workers.get(id, 0)
	var amount: int = SaveFile.get_settings_population_scale()
	if amount < 0:
		return workers
	return min(amount, workers)


##############
## handlers ##
##############


func _handle_add(worker_role: WorkerRole) -> void:
	var id: String = worker_role.id
	var amount: int = _get_settings_population_scale(Game.WORKER_RESOURCE_ID)
	SignalBus.worker_allocated.emit(id, amount, name)


func _handle_del(worker_role: WorkerRole) -> void:
	var id: String = worker_role.id
	var amount: int = _get_settings_population_scale(id)
	SignalBus.worker_allocated.emit(id, -amount, name)


## add all required roles automatically (auto-add ONLY FOR resources ... sergeant requires peasants)
func _handle_smart_add(worker_role: WorkerRole) -> void:
	var id: String = worker_role.id
	var required: Dictionary = requirements_map[id]
	var roles: int = DictionaryUtils.sum(required) + 1

	var mult: int = SaveFile.get_settings_population_scale()
	var total_roles: int = Limits.safe_mult(roles, mult)

	# cannot add more than global max, round down mult
	if total_roles >= Limits.GLOBAL_MAX_AMOUNT:
		mult = Limits.GLOBAL_MAX_AMOUNT / roles
		total_roles = roles * mult

	# cannot add more than peasant count, round down mult
	var peasants: int = SaveFile.workers.get(Game.WORKER_RESOURCE_ID, 0)
	if total_roles > peasants:
		mult = peasants / roles
		total_roles = roles * mult

	# cannot add more than food requirement
	var food_eff: int = worker_controller.get_efficiencies().get("resources", {}).get("food", 0)
	if food_eff < 0:
		SignalBus.worker_allocated.emit(id, 0, name)
		return
	var max_mult: int = food_eff / roles
	if mult > max_mult:
		mult = max_mult
		total_roles = roles * mult

	# only sergeant has worker role (peasants) requirements and only masons produce worker role
	if id == "sergeant":
		var masons: int = SaveFile.workers.get("mason", 0)
		var sergeants: int = SaveFile.workers.get("sergeant", 0)
		var population_production: int = Game.PARAMS["house_workers"] * masons - sergeants

		# cannot add more sergeant than peasant production, round down mult
		if mult > population_production:
			mult = population_production
			total_roles = roles * mult

	if total_roles <= 0:
		SignalBus.worker_allocated.emit(id, 0, name)
		return

	# workarounds for rounding errors near 10^18 (q = 10^15)
	var q: int = 1000000000000000
	var workers: int = SaveFile.workers.get(id, 0)
	# 1. workaround: round down mult to nearest multiple of 10^15
	if mult > q:
		var n: int = mult / q
		mult = q * n
		total_roles = roles * mult
	# 2. workaround: do not allow assigments less than 10^15 if amount is already larger than 10^15
	if workers > q and mult < q:
		SignalBus.worker_allocated.emit(id, 0, name)
		return

	for req: String in required:
		var amount: int = Limits.safe_mult(required[req], mult)
		SignalBus.worker_allocated.emit(req, amount, name)
	SignalBus.worker_allocated.emit(id, mult, name)


func _handle_smart_del(worker_role: WorkerRole) -> void:
	var id: String = worker_role.id
	var required: Dictionary = requirements_map[id]

	var mult: int = SaveFile.get_settings_population_scale()

	# cannot del more than required by other roles
	var produce_resource_id: String = worker_role.get_first_produce()
	if StringUtils.is_not_empty(produce_resource_id):
		var role_eff: int = worker_controller.get_efficiencies().get("resources", {}).get(
			produce_resource_id, 0
		)
		if role_eff < 0:
			SignalBus.worker_allocated.emit(id, 0, name)
			return
		mult = min(mult, role_eff)

	# cannot del more than assigned
	var workers: int = SaveFile.workers.get(id, 0)
	mult = min(mult, workers)

	if mult <= 0:
		SignalBus.worker_allocated.emit(id, 0, name)
		return

	for req: String in required:
		var amount: int = Limits.safe_mult(required[req], mult)
		var req_workers: int = SaveFile.workers.get(req, 0)
		amount = min(amount, req_workers)
		SignalBus.worker_allocated.emit(req, -amount, name)
	SignalBus.worker_allocated.emit(id, -mult, name)


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.manager_button_add.connect(_on_manager_button_add)
	SignalBus.manager_button_del.connect(_on_manager_button_del)
	SignalBus.manager_button_smart_add.connect(_on_manager_button_smart_add)
	SignalBus.manager_button_smart_del.connect(_on_manager_button_smart_del)


func _on_manager_button_add(worker_role: WorkerRole) -> void:
	_handle_add(worker_role)


func _on_manager_button_del(worker_role: WorkerRole) -> void:
	_handle_del(worker_role)


func _on_manager_button_smart_add(worker_role: WorkerRole) -> void:
	_handle_smart_add(worker_role)


func _on_manager_button_smart_del(worker_role: WorkerRole) -> void:
	_handle_smart_del(worker_role)
