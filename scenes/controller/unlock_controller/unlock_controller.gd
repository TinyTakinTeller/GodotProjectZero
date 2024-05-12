extends Node

@onready var firepit_timer: Timer = $FirepitTimer
@onready var house_timer: Timer = $HouseTimer


func _ready() -> void:
	SignalBus.resource_updated.connect(_on_resource_updated)
	SignalBus.worker_updated.connect(_on_worker_updated)
	firepit_timer.wait_time = Game.params["timer_firepit_seconds"]
	firepit_timer.timeout.connect(_on_firepit_timer_timeout)
	house_timer.wait_time = Game.params["timer_house_seconds"]
	house_timer.timeout.connect(_on_house_timer_timeout)


func _handle_resource_updated(observed_id: String, observed_total: int) -> void:
	if observed_id == "land":
		if ResourceManager.get_total_generated(observed_id) == 1:
			_trigger_unique_unlock_event("land_1")
			_unlock_resource_generator_if("FOREST")
			_level_up_tab("world", 1)
		if ResourceManager.get_total_generated(observed_id) == 2:
			_trigger_unique_unlock_event("land_2")
			_unlock_resource_generator_if("CREEK")
		if ResourceManager.get_total_generated(observed_id) == 3:
			_trigger_unique_unlock_event("land_3")
			_unlock_resource_generator_if("firepit")
		if ResourceManager.get_total_generated(observed_id) == 4:
			_trigger_unique_unlock_event("land_4")
			_unlock_resource_generator_if("axe")
			if Game.params["debug_gift"]:
				if _trigger_unique_unlock_event("land_debug"):
					_gift_resource("food", 100)
					_gift_resource("wood", 100)
					_gift_resource("stone", 100)
					_gift_resource("clay", 100)
					_gift_resource("brick", 100)
					_gift_resource("fiber", 100)
					_gift_resource("flint", 100)
					_gift_resource("fur", 100)
					_gift_resource("leather", 100)

		if ResourceManager.get_total_generated(observed_id) == 5:
			_trigger_unique_unlock_event("land_5")
			_unlock_resource_generator_if("pickaxe")
		if ResourceManager.get_total_generated(observed_id) == 6:
			_trigger_unique_unlock_event("land_6")
			_unlock_resource_generator_if("shovel")
		if ResourceManager.get_total_generated(observed_id) == 7:
			_trigger_unique_unlock_event("land_7")
			_unlock_resource_generator_if("spear")
		if ResourceManager.get_total_generated(observed_id) == 8:
			_trigger_unique_unlock_event("land_8")
			_unlock_resource_generator_if("compass")

	if observed_id == "firepit" and observed_total == 1:
		firepit_timer.start()
		_unlock_resource_generator_if("brick")
		_level_up_tab("world", 2)
		_unlock_worker_role_if("worker")
	if observed_id == "axe" and observed_total == 1:
		_unlock_resource_generator_if("wood")
	if observed_id == "pickaxe" and observed_total == 1:
		_unlock_resource_generator_if("stone")
	if observed_id == "shovel" and observed_total == 1:
		_unlock_resource_generator_if("clay")
	if observed_id == "spear" and observed_total == 1:
		_unlock_resource_generator_if("WILD")

	if observed_id == "brick" and observed_total >= 1:
		_unlock_resource_generator_if("house")

	if observed_id == "worker":
		if ResourceManager.get_total_generated(observed_id) >= 1:
			_unlock_tab_if("manager")
			_unlock_worker_role_if("lumberjack")
			_unlock_worker_role_if("stone_miner")
			_unlock_worker_role_if("clay_digger")
			_unlock_worker_role_if("smelter")
			_unlock_worker_role_if("hunter")
			_unlock_worker_role_if("tanner")
			## _unlock_worker_role_if("FLINT_GENERATOR")
			## _unlock_worker_role_if("FIBER_GENERATOR")
			## _unlock_worker_role_if("tailor")

	if observed_id == "house":
		if observed_total == 1:
			house_timer.start()
			_trigger_unique_unlock_event("house_1")
		if observed_total == 4:
			_level_up_tab("world", 3)
			_trigger_unique_unlock_event("house_4")
		if observed_total == 25:
			_level_up_tab("world", 4)


func _handle_worker_updated(_observed_id: String, _observed_total: int) -> void:
	pass  #_unlock_manager_button_if("recruiter", observed_id == "explorer", observed_total >= 1)


func _level_up_tab(tab_id: String, level: int) -> void:
	var tab_data: TabData = Resources.tab_datas[tab_id]
	if tab_data.level < level:
		SignalBus.tab_level_up.emit(tab_data)


func _trigger_unique_unlock_event(event_id: String) -> bool:
	if SaveFile.events.get(event_id, 0) == 0:
		var event_data: EventData = Resources.event_datas[event_id]
		SignalBus.event_triggered.emit(event_data, [])
		return true
	return false


func _unlock_resource_generator_if(
	unlock_id: String,
) -> void:
	if !SaveFile.resource_generator_unlocks.has(unlock_id):
		var resource_generator: ResourceGenerator = Resources.resource_generators[unlock_id]
		SignalBus.progress_button_unlock.emit(resource_generator)


func _unlock_worker_role_if(unlock_id: String) -> void:
	if !SaveFile.worker_role_unlocks.has(unlock_id):
		var worker_role: WorkerRole = Resources.worker_roles[unlock_id]
		SignalBus.manager_button_unlock.emit(worker_role)


func _unlock_tab_if(unlock_id: String) -> void:
	if !SaveFile.tab_unlocks.has(unlock_id):
		var tab_data: TabData = Resources.tab_datas[unlock_id]
		SignalBus.tab_unlock.emit(tab_data)


func _gift_resource(gen_id: String, amount: int) -> void:
	SignalBus.resource_generated.emit(gen_id, amount, name)


func _on_resource_updated(id: String, total: int, amount: int, _source_id: String) -> void:
	if amount > 0:
		_handle_resource_updated(id, total)


func _on_worker_updated(id: String, total: int, _amount: int) -> void:
	_handle_worker_updated(id, total)


func _on_firepit_timer_timeout() -> void:
	_trigger_unique_unlock_event("firepit_worker")
	_gift_resource("worker", 1)


func _on_house_timer_timeout() -> void:
	var max_workers: int = Game.params["house_workers"] * SaveFile.resources.get("house", 0)
	if SaveFile.resources.get("worker", 0) < max_workers:
		_gift_resource("worker", 1)
