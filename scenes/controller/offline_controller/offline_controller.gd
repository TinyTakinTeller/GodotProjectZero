class_name OfflineController
extends Node

@export var worker_controller: WorkerController
@export var enemy_controller: EnemyController

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

	# normalize "house -> worker" production
	if total_efficiency.has("house"):
		var worker_inc: int = Limits.safe_mult(
			Game.PARAMS["house_workers"], total_efficiency.get("house", 0)
		)
		total_efficiency["worker"] = worker_inc
	else:
		total_efficiency["worker"] = 0

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
	var enemy_health: int = enemy_data.health_points
	var overkill_factor: float = MathUtils.dual_sum_normalized(
		swordsman_storage, swordsman_eff, cycles, enemy_health
	)
	var damage: int = MathUtils.safe_dual_sum(swordsman_storage, swordsman_eff, cycles)

	var generated: Dictionary = {}
	if enemy_data.is_last() && overkill_factor >= 1.0:
		generated["soulstone"] = int(overkill_factor)
	return {"overkill_factor": overkill_factor, "damage": damage, "generated": generated}


##############
## handlers ##
##############


func _handle_on_game_resumed(
	seconds_delta: int, seconds_delta_expected: int, factor: float = 1.0
) -> void:
	var threshold: int = seconds_delta_expected + 1
	if seconds_delta < threshold:
		return

	var efficiencies: Dictionary = worker_controller.get_efficiencies()
	var worker_controller_cycle: int = worker_controller.CYCLE_SECONDS
	var worker_controller_cycles: int = seconds_delta / worker_controller_cycle
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
	var enemy_controller_cycle: float = enemy_controller.get_cycle_duration()
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
		seconds_delta, worker_progress, enemy_progress, factor
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
