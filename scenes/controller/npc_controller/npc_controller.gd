class_name NpcController
extends Node

###############
## overrides ##
###############


func _ready() -> void:
	_connect_signals()


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.npc_event_interacted.connect(_on_npc_event_interacted)


func _on_npc_event_interacted(npc_id: String, npc_event_id: String, option: int) -> void:
	var npc_event: NpcEvent = Resources.npc_events.get(npc_event_id, null)
	if npc_event == null:
		return

	if option < npc_event.next_npc_event_id.size():
		var follow_up_event_id: String = npc_event.next_npc_event_id[option]
		var follow_up_event: NpcEvent = Resources.npc_events.get(follow_up_event_id, null)
		if follow_up_event != null:
			SignalBus.npc_event_triggered.emit(follow_up_event)

	SignalBus.npc_event_update.emit(npc_id, npc_event_id, option)
