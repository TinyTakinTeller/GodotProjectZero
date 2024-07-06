extends Node

@export var sfx_unlock: AudioStream

@onready var cat_intro_timer: Timer = $CatIntroTimer

###############
## overrides ##
###############


func _ready() -> void:
	_load_timers()
	_connect_signals()


##############
## handlers ##
##############


func _handle_on_resource_increased(observed_id: String, observed_total: int) -> void:
	if observed_id == "land":
		_handle_land_event(observed_id)
	if observed_id == "house":
		_handle_house_event(observed_total)

	if observed_id == "firepit" and observed_total == 1:
		_unlock_resource_generator_if("brick")
		_level_up_tab("world", 2)
		_unlock_worker_role_if("worker")
	if observed_id == "axe" and observed_total == 1:
		_unlock_resource_generator_if("wood")
		_unlock_worker_role_if("lumberjack")
	if observed_id == "pickaxe" and observed_total == 1:
		_unlock_resource_generator_if("stone")
		_unlock_worker_role_if("stone_miner")
	if observed_id == "shovel" and observed_total == 1:
		_unlock_resource_generator_if("clay")
		_unlock_worker_role_if("clay_digger")
	if observed_id == "spear" and observed_total == 1:
		_unlock_resource_generator_if("WILD")
		_unlock_worker_role_if("hunter")
		_unlock_worker_role_if("tanner")

	if observed_id == "brick" and observed_total >= 1:
		_unlock_resource_generator_if("house")

	if observed_id == "worker":
		if ResourceManager.get_total_generated(observed_id) >= 1:
			_trigger_unique_unlock_event("firepit_worker")
			_unlock_tab_if("manager")
			_unlock_worker_role_if("smelter")
			# _unlock_worker_role_if("FLINT_GENERATOR")
			# _unlock_worker_role_if("FIBER_GENERATOR")

	if observed_id == "compass" and observed_total == 1:
		_trigger_unique_unlock_event("enemy_screen")
		_unlock_tab_if("enemy")
		_unlock_resource_generator_if("sword")

	if observed_id == "sword" and observed_total >= 1:
		_unlock_resource_generator_if("swordsman")
		_unlock_worker_role_if("swordsmith")

	if observed_id == "swordsman" and observed_total >= 1:
		_unlock_worker_role_if("swordsman")
		_unlock_worker_role_if("sergeant")
		_unlock_worker_role_if("mason")

	if observed_id == "beacon" and observed_total == 1:
		_unlock_tab_if("starway")
		_trigger_unique_unlock_event("lore_beacon")


func _handle_worker_updated(_observed_id: String, _observed_total: int) -> void:
	pass  #_unlock_manager_button_if("recruiter", observed_id == "explorer", observed_total >= 1)


func _handle_npc_event_interacted(npc_id: String, npc_event_id: String, option: int) -> void:
	if npc_id == "cat":
		if npc_event_id == "cat_intro":
			if option == 0:
				_trigger_unique_unlock_event("cat_intro_yes")
			elif option == 1:
				_trigger_unique_unlock_event("cat_intro_no")
		elif npc_event_id == "cat_talk_A4":
			if option == 0:
				_gift_double()
			else:
				_trigger_unique_unlock_event("cat_no_gift")
		elif npc_event_id == "cat_talk_B4":
			if option == 0:
				_gift_double()  # _gift_scam()
			else:
				_trigger_unique_unlock_event("cat_no_gift")


func _handle_land_event(observed_id: String) -> void:
	if ResourceManager.get_total_generated(observed_id) >= 1:
		_trigger_unique_unlock_event("land_1")
		_unlock_resource_generator_if("FOREST")
		_level_up_tab("world", 1)
	if ResourceManager.get_total_generated(observed_id) >= 2:
		_trigger_unique_unlock_event("land_2")
		_unlock_resource_generator_if("CREEK")
	if ResourceManager.get_total_generated(observed_id) >= 3:
		_trigger_unique_unlock_event("cat_watching")
		if _trigger_unique_unlock_npc_event("cat", "cat_peek"):
			cat_intro_timer.start()
	if ResourceManager.get_total_generated(observed_id) >= 3 + 1:
		_trigger_unique_unlock_event("land_3")
		_unlock_resource_generator_if("firepit")
	if ResourceManager.get_total_generated(observed_id) >= 4 + 1:
		_trigger_unique_unlock_event("land_4")
		_unlock_resource_generator_if("axe")
		_gift_debug()
	if ResourceManager.get_total_generated(observed_id) >= 5 + 1:
		_trigger_unique_unlock_event("land_5")
		_unlock_resource_generator_if("pickaxe")
	if ResourceManager.get_total_generated(observed_id) >= 6 + 1:
		_trigger_unique_unlock_event("land_6")
		_unlock_resource_generator_if("shovel")
	if ResourceManager.get_total_generated(observed_id) >= 7 + 1:
		_trigger_unique_unlock_event("land_7")
		_unlock_resource_generator_if("spear")
	if ResourceManager.get_total_generated(observed_id) >= 8 + 1:
		if _trigger_unique_unlock_event_values("gift_flint_fiber", ["2", "1", "5", "3"]):
			_gift_resource("fiber", 2, name)
			_gift_resource("flint", 1, name)
			_gift_resource("wood", 5, name)
			_gift_resource("stone", 3, name)
	if ResourceManager.get_total_generated(observed_id) >= 8 + 2:
		_trigger_unique_unlock_event("land_8")
		_unlock_resource_generator_if("compass")
	if ResourceManager.get_total_generated(observed_id) >= 9 + 2:
		_trigger_unique_unlock_event("land_9")
		_unlock_worker_role_if("explorer")
		_unlock_resource_generator_if("torch")
	if ResourceManager.get_total_generated(observed_id) >= 10 + 2:
		_trigger_unique_unlock_event("land_10")
		_unlock_worker_role_if("coal_miner")
		_unlock_worker_role_if("torch_man")
	if ResourceManager.get_total_generated(observed_id) >= 11 + 2:
		_trigger_unique_unlock_event("land_11")
		_unlock_worker_role_if("iron_miner")
		_unlock_worker_role_if("iron_smelter")


func _handle_house_event(observed_total: int) -> void:
	if observed_total >= 1:
		_trigger_unique_unlock_event("house_1")
	if observed_total >= 4:
		_trigger_unique_unlock_event("house_4")
	if observed_total >= 25:
		_trigger_unique_unlock_event("house_25")
		_level_up_tab("world", 3)
	if observed_total >= 100:
		_trigger_unique_unlock_event("house_100")
		_level_up_tab("world", 4)
	if observed_total >= 1000:
		_trigger_unique_unlock_event("house_town")
		_level_up_tab("world", 5)
	if observed_total >= 10000:
		_trigger_unique_unlock_event("house_city")
		_level_up_tab("world", 6)
	if observed_total >= 100000:
		_trigger_unique_unlock_event("house_capital")
		_level_up_tab("world", 7)
	if observed_total >= 1000000:
		_trigger_unique_unlock_event("house_metropolis")
		_level_up_tab("world", 8)
	if observed_total >= 10000000:
		_trigger_unique_unlock_event("house_megalopolis")
		_level_up_tab("world", 9)
	if observed_total >= 100000000:
		_trigger_unique_unlock_event("house_kingdom")
		_level_up_tab("world", 10)
	if observed_total >= 1000000000:
		_trigger_unique_unlock_event("house_empire")
		_level_up_tab("world", 11)
	if observed_total >= 10000000000:
		_trigger_unique_unlock_event("house_imperium")
		_level_up_tab("world", 12)


func _handle_on_deaths_door_resolved(enemy_data: EnemyData, option: int) -> void:
	_unlock_tab_if("soul")
	_unlock_resource_generator_if("beacon")
	if option == 0:
		return
	_deaths_door_event(option, enemy_data.order)


func _handle_on_deaths_door_open(enemy_data: EnemyData) -> void:
	if enemy_data.order <= 10:
		_deaths_door_lore(enemy_data.order)


#############
## helpers ##
#############


func _deaths_door_event(option: int, level: int) -> void:
	var event_id: String = ("execute_" if option == 1 else "absolve_") + str(level)
	if level > 9:
		return
	_trigger_unique_unlock_event(event_id)


func _deaths_door_lore(level: int) -> void:
	var event_id: String = "darkness_" + str(level)
	_trigger_unique_unlock_event(event_id)


func _load_timers() -> void:
	cat_intro_timer.wait_time = Game.params["timer_cat_intro_seconds"]
	cat_intro_timer.one_shot = true
	if SaveFile.events.get("cat_watching", 0) == 1:
		cat_intro_timer.start()


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


func _trigger_unique_unlock_event_values(event_id: String, vals: Array) -> bool:
	if SaveFile.events.get(event_id, 0) == 0:
		var event_data: EventData = Resources.event_datas[event_id]
		SignalBus.event_triggered.emit(event_data, vals)
		return true
	return false


func _trigger_unique_unlock_npc_event(npc_id: String, npc_event_id: String) -> bool:
	var npc_events: Dictionary = SaveFile.npc_events.get(npc_id, {})
	if npc_events.get(npc_event_id, -1) == -1:
		var npc_event: NpcEvent = Resources.npc_events[npc_event_id]
		SignalBus.npc_event_triggered.emit(npc_event)
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


func _play_sfx_unlock() -> void:
	if sfx_unlock:
		Audio.play_sfx_id("unlock_controller_unlock", 0.0)


func _gift_resource(gen_id: String, amount: int, source_id: String) -> void:
	if amount != 0:
		SignalBus.resource_generated.emit(gen_id, amount, source_id)


func _gift_debug() -> void:
	if Game.params["debug_gift"]:
		if _trigger_unique_unlock_event("land_debug"):
			_gift_resource("food", 1000, name)
			_gift_resource("wood", 1000, name)
			_gift_resource("stone", 1000, name)
			_gift_resource("clay", 1000, name)
			_gift_resource("brick", 1000, name)
			_gift_resource("fiber", 1000, name)
			_gift_resource("flint", 1000, name)
			_gift_resource("fur", 1000, name)
			_gift_resource("leather", 1000, name)


func _gift_double() -> void:
	if _trigger_unique_unlock_event("cat_gift"):
		_gift_resource("soulstone", SaveFile.resources.get("soulstone", 0), name)
		_gift_resource("food", SaveFile.resources.get("food", 0), name)
		_gift_resource("wood", SaveFile.resources.get("wood", 0), name)
		_gift_resource("stone", SaveFile.resources.get("stone", 0), name)
		_gift_resource("clay", SaveFile.resources.get("clay", 0), name)
		_gift_resource("brick", SaveFile.resources.get("brick", 0), name)
		_gift_resource("fur", SaveFile.resources.get("fur", 0), name)
		_gift_resource("leather", SaveFile.resources.get("leather", 0), name)
		_gift_resource("coal", SaveFile.resources.get("coal", 0), name)
		_gift_resource("iron_ore", SaveFile.resources.get("iron_ore", 0), name)
		_gift_resource("iron", SaveFile.resources.get("iron", 0), name)
		_gift_resource("fiber", SaveFile.resources.get("fiber", 0), name)
		_gift_resource("flint", SaveFile.resources.get("flint", 0), name)


func _gift_scam() -> void:
	if _trigger_unique_unlock_event("cat_scam"):
		_gift_resource("soulstone", -SaveFile.resources.get("soulstone", 0), name)
		_gift_resource("food", -SaveFile.resources.get("food", 0), name)
		_gift_resource("wood", -SaveFile.resources.get("wood", 0), name)
		_gift_resource("stone", -SaveFile.resources.get("stone", 0), name)
		_gift_resource("clay", -SaveFile.resources.get("clay", 0), name)
		_gift_resource("brick", -SaveFile.resources.get("brick", 0), name)
		_gift_resource("fur", -SaveFile.resources.get("fur", 0), name)
		_gift_resource("leather", -SaveFile.resources.get("leather", 0), name)
		_gift_resource("coal", -SaveFile.resources.get("coal", 0), name)
		_gift_resource("iron_ore", -SaveFile.resources.get("iron_ore", 0), name)
		_gift_resource("iron", -SaveFile.resources.get("iron", 0), name)
		_gift_resource("fiber", -SaveFile.resources.get("fiber", 0), name)
		_gift_resource("flint", -SaveFile.resources.get("flint", 0), name)


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.resource_updated.connect(_on_resource_updated)
	SignalBus.worker_updated.connect(_on_worker_updated)
	SignalBus.npc_event_interacted.connect(_on_npc_event_interacted)
	cat_intro_timer.timeout.connect(_on_timer_cat_timeout)
	SignalBus.deaths_door_resolved.connect(_on_deaths_door_resolved)
	SignalBus.deaths_door_open.connect(_on_deaths_door_open)
	SignalBus.progress_button_unlocked.connect(_on_progress_button_unlocked)
	SignalBus.manager_button_unlocked.connect(_on_manager_button_unlocked)
	SignalBus.tab_unlocked.connect(_on_tab_unlocked)


func _on_resource_updated(id: String, total: int, amount: int, _source_id: String) -> void:
	if amount > 0:
		_handle_on_resource_increased(id, total)


func _on_worker_updated(id: String, total: int, _amount: int) -> void:
	_handle_worker_updated(id, total)


func _on_npc_event_interacted(npc_id: String, npc_event_id: String, option: int) -> void:
	_handle_npc_event_interacted(npc_id, npc_event_id, option)


func _on_timer_cat_timeout() -> void:
	if SaveFile.events.get("cat_watching", 0) == 1:
		_trigger_unique_unlock_npc_event("cat", "cat_intro")


func _on_deaths_door_resolved(
	enemy_data: EnemyData, _new_enemy_data: EnemyData, option: int
) -> void:
	_handle_on_deaths_door_resolved(enemy_data, option)


func _on_deaths_door_open(enemy_data: EnemyData) -> void:
	_handle_on_deaths_door_open(enemy_data)


func _on_progress_button_unlocked(_resource_generator: ResourceGenerator) -> void:
	_play_sfx_unlock()


func _on_manager_button_unlocked(_worker_role: WorkerRole) -> void:
	_play_sfx_unlock()


func _on_tab_unlocked(_tab_data: TabData) -> void:
	_play_sfx_unlock()
