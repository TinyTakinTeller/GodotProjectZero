class_name OfflineController
extends Node

@export var worker_controller: WorkerController
@export var enemy_controller: EnemyController
@export var manager_button_controller: ManagerButtonController

@onready var auto_mason: AutoMason = $AutoMason

###############
## overrides ##
###############


func _ready() -> void:
	_connect_signals()


#############
## helpers ##
#############


## Workers must be "happy" to work while not observed (none of the resources are decreasing).
func _progress_worker_controller(efficiencies: Dictionary, cycles: int) -> Dictionary:
	var total_efficiency: Dictionary = efficiencies["total_efficiency"]
	var storage: Dictionary = efficiencies["storage"]

	# normalize "house -> worker" production
	if total_efficiency.has("house"):
		var house_workers: int = SaveFile.get_house_workers()
		var worker_inc: int = Limits.safe_mult(house_workers, total_efficiency.get("house", 0))
		total_efficiency[Game.WORKER_RESOURCE_ID] = worker_inc
	else:
		total_efficiency[Game.WORKER_RESOURCE_ID] = 0

	# check for decreasing resources
	var ids: Array = total_efficiency.keys()
	var decreasing_ids: Array = ids.filter(
		func(id: String) -> bool: return total_efficiency[id] < 0
	)
	if !decreasing_ids.is_empty():
		return {"decreasing_ids": decreasing_ids, "generated": {}}

	# calculate production for cycles
	var generated: Dictionary = {}
	for id: String in ids:
		var id_eff: int = total_efficiency[id]
		var resource: ResourceGenerator = Resources.resource_generators[id]
		if resource.is_dynamic_efficiency():
			var de_id: String = resource.dynamic_efficiency_id
			var de_id_eff: int = total_efficiency[de_id]
			var generate: int = MathUtils.safe_dual_sum(id_eff, de_id_eff, cycles)
			generated[id] = Limits.safe_add(generated.get(id, 0), generate)
		else:
			var generate: int = Limits.safe_mult(id_eff, cycles)
			generated[id] = Limits.safe_add(generated.get(id, 0), generate)

	var nonzero_generated: Dictionary = {}
	for id: String in generated:
		if generated[id] != 0:
			nonzero_generated[id] = generated[id]

	# the_hierophant effect
	var has_the_hierophant: bool = SaveFile.substances.get("the_hierophant", 0) > 0
	var mode: int = SaveFile.settings.get("manager_mode", 0)
	var freemasonry: bool = has_the_hierophant and mode == 2
	if freemasonry:
		var h: int = storage.get("house", 0)
		var w: int = storage.get("worker", 0)
		if h > 0 and w > 0 and h < Limits.GLOBAL_MAX_AMOUNT and w < Limits.GLOBAL_MAX_AMOUNT:
			var m: int = max(SaveFile.workers.get("mason", 0), 1)
			var s: int = SaveFile.workers.get("sergeant", 0)
			var mason_req: int = manager_button_controller.get_total_requirements_sum("mason")
			var house_workers: int = SaveFile.get_house_workers()
			var n: int = cycles
			var per_cent: int = SaveFile.get_shadow_percent() + 100
			auto_mason.clear_cache(h, m, house_workers, mason_req, w, s, per_cent)
			var results: Dictionary = auto_mason.cycles(n)

			var gen_house: int = max(results["h"], nonzero_generated.get("house", 0))
			if gen_house > 0:
				nonzero_generated["house"] = gen_house
			var gen_worker: int = max(results["p"], nonzero_generated.get("worker", 0))
			if gen_worker > 0:
				nonzero_generated["worker"] = gen_worker

			# the_hanged_man effect
			var has_the_hanged_man: bool = SaveFile.substances.get("the_hanged_man", 0) > 0
			if has_the_hanged_man:
				var maxed: bool = results.get("max", false)
				var cycles_left: int = n - results.get("i", n)
				if maxed and cycles_left > 0:
					var max_swordsman_per_cycle: int = 16000000000000000  # 16q
					var gen_swordsman: int = max(
						Limits.safe_mult(cycles_left, max_swordsman_per_cycle),
						nonzero_generated.get("swordsman", 0)
					)
					if gen_swordsman > 0:
						nonzero_generated["swordsman"] = gen_swordsman

	return {"decreasing_ids": [], "generated": nonzero_generated}


func _generate_resources(generated: Dictionary) -> bool:
	var is_success: bool = false
	for resource_id: String in generated:
		var amount: int = generated[resource_id]
		if amount == 0:
			continue
		is_success = true
		SignalBus.resource_generated.emit(resource_id, amount, name)

		var resource: ResourceGenerator = Resources.resource_generators[resource_id]
		var worker_costs: Dictionary = resource.worker_costs
		for worker_id: String in worker_costs:
			var cost: int = Limits.safe_mult(amount, worker_costs[worker_id])
			SignalBus.worker_generated.emit(worker_id, -cost, name)
	return is_success


func _progress_enemy_controller(
	swordsman_storage: int, swordsman_eff: int, cycles: int, enemy_data: EnemyData
) -> Dictionary:
	var ratio: int = Game.PARAMS["spirit_bonus"]
	var spirit_count: int = SaveFile.get_spirit_substance_count()

	var enemy_health: int = enemy_data.health_points
	var overkill_factor: float = abs(
		MathUtils.dual_sum_normalized(swordsman_storage, swordsman_eff, cycles, enemy_health)
	)
	if swordsman_storage >= Limits.GLOBAL_MAX_AMOUNT:  # WORKAROUND FOR ADF-64
		overkill_factor = Limits.safe_mult(swordsman_storage / enemy_health, cycles)

	var damage: int = MathUtils.safe_dual_sum(swordsman_storage, swordsman_eff, cycles)
	damage = max(
		Limits.safe_mult(damage, spirit_count + ratio) / ratio,
		Limits.safe_mult(damage, max(1, (spirit_count + ratio) / ratio))
	)

	var generated: Dictionary = {}
	if enemy_data.is_last() && overkill_factor >= 1.0:
		generated["soulstone"] = max(
			Limits.safe_mult(int(overkill_factor), spirit_count + ratio) / ratio,
			Limits.safe_mult(int(overkill_factor), max(1, (spirit_count + ratio) / ratio)),
		)

	if not generated.has("soulstone"):
		generated["soulstone"] = 0

	var has_mult: bool = SaveFile.substances.get("the_high_priestess", 0) > 0
	if has_mult:
		var mult: int = max(1, SaveFile.resources.get("singularity", 0))
		generated["soulstone"] = Limits.safe_mult(generated["soulstone"], mult)

	if generated.has("soulstone") and generated.get("soulstone", 0) == 0:
		generated.erase("soulstone")

	return {"overkill_factor": overkill_factor, "damage": damage, "generated": generated}


func progress_death_charm(death_cycles: int) -> Dictionary:
	var has_death: bool = SaveFile.substances.get("death", 0) > 0
	if not has_death:
		return {}

	return {"singularity": Limits.safe_mult(death_cycles, 18), "heart": death_cycles}


##############
## handlers ##
##############


func _handle_on_game_resumed(
	seconds_delta: int, seconds_delta_expected: int, factor: float = 1.0
) -> void:
	var threshold: int = seconds_delta_expected + 1
	if seconds_delta < threshold:
		return

	# handle death charm before everything else
	var death_cycle: float = float(SaveFile.best_prestige_delta())
	var death_cycles: int = int(float(seconds_delta) / death_cycle)
	var death_progress: Dictionary = progress_death_charm(death_cycles)
	if not death_progress.is_empty():
		SignalBus.substance_multiple_generated.emit("heart", death_progress.get("heart", 0), name)
		SignalBus.resource_generated.emit("singularity", death_progress.get("singularity", 0), name)

	var efficiencies: Dictionary = worker_controller.get_efficiencies()
	var worker_controller_cycle: float = SaveFile.get_cycle_seconds()
	var worker_controller_cycles: int = int(float(seconds_delta) / worker_controller_cycle)
	worker_controller_cycles = int(factor * worker_controller_cycles)
	var worker_progress: Dictionary = _progress_worker_controller(
		efficiencies, worker_controller_cycles
	)

	var generated: Dictionary = worker_progress["generated"]

	# var decreasing_ids: Array = worker_progress["decreasing_ids"]
	# var workers_are_happy: bool = decreasing_ids.is_empty()

	var enemy_id: String = SaveFile.enemy["level"]
	var enemy_data: EnemyData = Resources.enemy_datas.get(enemy_id, null)
	var swordsman_storage: int = efficiencies.get("storage", {}).get("swordsman", 0)
	var swordsman_eff: int = efficiencies.get("total_efficiency", {}).get("swordsman", 0)
	var enemy_controller_cycle: float = SaveFile.get_enemy_cycle_seconds()
	var enemy_controller_cycles: int = int(float(seconds_delta) / enemy_controller_cycle)
	enemy_controller_cycles = int(factor * enemy_controller_cycles)
	var enemy_progress: Dictionary = _progress_enemy_controller(
		swordsman_storage, swordsman_eff, enemy_controller_cycles, enemy_data
	)
	var damage: int = enemy_progress["damage"]
	# var overkill_factor: float = enemy_progress["overkill_factor"]
	DictionaryUtils.merge_sum_int(generated, enemy_progress["generated"])

	_generate_resources(generated)
	if !enemy_data.is_last():
		SignalBus.enemy_damage.emit(damage, name)

	SignalBus.offline_progress_processed.emit(
		seconds_delta, worker_progress, enemy_progress, factor, death_progress
	)

	if Game.PARAMS["debug_logs"]:
		prints("_handle_on_game_resumed", seconds_delta, seconds_delta_expected)
		prints("_generate_resources", worker_controller_cycles, worker_progress)
		prints("_trigger_enemy_controller", enemy_controller_cycles, enemy_progress)


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.save_entered.connect(_on_save_entered)
	SignalBus.autosave.connect(_on_autosave)


## detect when a save file was (re)opened
func _on_save_entered(seconds_delta: int, seconds_delta_expected: int) -> void:
	_handle_on_game_resumed(seconds_delta, seconds_delta_expected)


## detect when an inactive web browser tab (paused game) was resumed (delta will be above expected)
func _on_autosave(seconds_delta: int, seconds_delta_expected: int) -> void:
	_handle_on_game_resumed(seconds_delta, seconds_delta_expected)
