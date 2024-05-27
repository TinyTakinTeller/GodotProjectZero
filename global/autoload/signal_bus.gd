extends Node

## UI
signal progress_button_hover(resource_generator: ResourceGenerator)
signal progress_button_unhover(resource_generator: ResourceGenerator)
signal progress_button_pressed(resource_generator: ResourceGenerator)
signal progress_button_disabled(id: String)
signal manager_button_hover(worker_role: WorkerRole)
signal manager_button_add(worker_role: WorkerRole)
signal manager_button_del(worker_role: WorkerRole)
signal npc_event_interacted(npc_id: String, npc_event_id: String, option: int)
signal enemy_hover(enemy_data: EnemyData)
signal tab_changed(tab_data: TabData)
signal toggle_button_pressed(id: String, toggle_id: String)
signal resource_ui_updated(
	resource_tracker_item: ResourceTrackerItem, amount: int, change: int, source_id: String
)

## CONTROLLER
signal progress_button_paid(resource_generator: ResourceGenerator)
signal progress_button_unpaid(resource_generator: ResourceGenerator)
signal resource_generated(id: String, amount: int, source_id: String)
signal worker_generated(id: String, amount: int, source_id: String)
signal worker_allocated(id: String, amount: int, source_id: String)
signal event_triggered(event_data: EventData, vals: Array)
signal npc_event_triggered(npc_event: NpcEvent)
signal progress_button_unlock(resource_generator: ResourceGenerator)
signal manager_button_unlock(worker_role: WorkerRole)
signal tab_unlock(tab_data: TabData)
signal tab_level_up(tab_data: TabData)
signal worker_efficiency_updated(efficiencies: Dictionary, generate: bool)
signal enemy_damage(damage: int, source_id: String)
signal set_ui_theme(theme: Resource)

## MANAGER
signal resource_updated(id: String, total: int, amount: int, source_id: String)
signal worker_updated(id: String, total: int, amount: int)
signal event_saved(event_data: EventData, vals: Array, index: int)
signal npc_event_saved(npc_event: NpcEvent)
signal progress_button_unlocked(resource_generator: ResourceGenerator)
signal manager_button_unlocked(worker_role: WorkerRole)
signal tab_unlocked(tab_data: TabData)
signal tab_leveled_up(tab_data: TabData)
signal enemy_damaged(total_damage: int, damage: int, source_id: String)


func _ready() -> void:
	if Game.params["debug_logs"]:
		print("_AUTOLOAD _READY: " + self.get_name())
