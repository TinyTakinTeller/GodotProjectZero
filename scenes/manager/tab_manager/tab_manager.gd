extends Node


func _ready() -> void:
	SignalBus.tab_unlock.connect(_on_tab_unlock)
	SignalBus.tab_level_up.connect(_on_tab_level_up)


func _unlock_tab(tab_data: TabData) -> void:
	var tab_data_id: String = tab_data.id
	SaveFile.tab_unlocks.append(tab_data_id)
	SaveFile.tab_levels[tab_data_id] = 0
	SignalBus.tab_unlocked.emit(tab_data)


func _level_up_tab(tab_data: TabData) -> void:
	var tab_data_id: String = tab_data.id
	SaveFile.tab_levels[tab_data_id] = SaveFile.tab_levels.get(tab_data_id, 0) + 1
	SignalBus.tab_leveled_up.emit(tab_data)


func _on_tab_unlock(tab_data: TabData) -> void:
	_unlock_tab(tab_data)


func _on_tab_level_up(tab_data: TabData) -> void:
	_level_up_tab(tab_data)
