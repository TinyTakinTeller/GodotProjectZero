extends Node
class_name NpcManager

###############
## overrides ##
###############


func _ready() -> void:
	_connect_signals()


##############
## handlers ##
##############


func _add_npc_event(npc_event: NpcEvent) -> void:
	var npc_id: String = npc_event.get_npc_id()
	var npc_event_id: String = npc_event.get_id()
	if !SaveFile.npc_events.has(npc_id):
		SaveFile.npc_events[npc_id] = {}
	SaveFile.npc_events[npc_id][npc_event_id] = 0
	SignalBus.npc_event_saved.emit(npc_event)


func _update_npc_event(npc_id: String, npc_event_id: String, option: int) -> void:
	if !SaveFile.npc_events.has(npc_id):
		SaveFile.npc_events[npc_id] = {}
	SaveFile.npc_events[npc_id][npc_event_id] = option
	# SignalBus.npc_event_updated.emit()


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.npc_event_triggered.connect(_on_npc_event_triggered)
	SignalBus.npc_event_interacted.connect(_on_npc_event_interacted)


func _on_npc_event_triggered(npc_event: NpcEvent) -> void:
	_add_npc_event(npc_event)


func _on_npc_event_interacted(npc_id: String, npc_event_id: String, option: int) -> void:
	_update_npc_event(npc_id, npc_event_id, option)
