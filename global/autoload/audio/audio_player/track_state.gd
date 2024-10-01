extends StateMachineState

const TWEEN_TRANSITION_TIME: float = 1.0

var track: AudioStreamPlayer
var _transition_tween: Tween
var _is_active: bool = false

@onready var audio_player: AudioPlayer = owner

###############
## overrides ##
###############


func _on_ready() -> void:
	await audio_player.ready
	track = audio_player.tracks.get_node(NodePath(self.name))
	track.volume_db = linear_to_db(0.0)
	audio_player.master_volume_changed.connect(_on_master_volume_changed)


func _on_state_enter() -> void:
	print("entered state: %s" % self.name)
	_is_active = true
	var from_volume: float = 0.0
	var to_volume: float = audio_player.master_volume
	transition_volume(from_volume, to_volume)


func _on_state_exit() -> void:
	print("exited state: %s" % self.name)
	_is_active = false
	var from_volume: float = audio_player.master_volume
	var to_volume: float = 0.0
	transition_volume(from_volume, to_volume)


#############
## methods ##
#############


func set_volume(volume: float) -> void:
	track.volume_db = linear_to_db(volume)


func transition_volume(from_volume: float, to_volume: float) -> void:
	if _transition_tween != null:
		_transition_tween.kill()
	_transition_tween = create_tween()

	_transition_tween.tween_method(set_volume, from_volume, to_volume, TWEEN_TRANSITION_TIME)


###############
## signals ##
###############


func _on_master_volume_changed(volume: float) -> void:
	if linear_to_db(volume) < track.volume_db || _is_active:
		set_volume(volume)
