extends Node

###############
## overrides ##
###############


func _ready() -> void:
	_connect_signals()


##############
## handlers ##
##############


func _handle_on_tab_unlock(tab_data: TabData) -> void:
	var tab_data_id: String = tab_data.id
	SaveFile.tab_unlocks.append(tab_data_id)
	SaveFile.tab_levels[tab_data_id] = 0
	SignalBus.tab_unlocked.emit(tab_data)


func _handle_on_tab_level_up(tab_data: TabData) -> void:
	var tab_data_id: String = tab_data.id
	SaveFile.tab_levels[tab_data_id] = SaveFile.tab_levels.get(tab_data_id, 0) + 1
	SignalBus.tab_leveled_up.emit(tab_data)


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.tab_unlock.connect(_on_tab_unlock)
	SignalBus.tab_level_up.connect(_on_tab_level_up)


func _on_tab_unlock(tab_data: TabData) -> void:
	_handle_on_tab_unlock(tab_data)


func _on_tab_level_up(tab_data: TabData) -> void:
	_handle_on_tab_level_up(tab_data)
