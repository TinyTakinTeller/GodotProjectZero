class_name AudioQueue extends Node

@export var stream_player_count: int = 4
@export_enum(&"Master", &"Music", &"SFX") var bus: String = &"Master"

var _available_stream_players: Array[AudioStreamPlayer] = []
var _audio_queue: Array[AudioItem] = []


class AudioItem:
	var stream: AudioStream
	var pitch_scale: float


###############
## overrides ##
###############


func _ready() -> void:
	for i in stream_player_count:
		var stream_player: AudioStreamPlayer = AudioStreamPlayer.new()
		add_child(stream_player)
		stream_player.finished.connect(_on_stream_player_finished.bind(stream_player))
		_available_stream_players.append(stream_player)


#############
## methods ##
#############


func play(stream: AudioStream, pitch_variance: float) -> void:
	var pitch_scale: float = randf_range(1.0 - pitch_variance, 1.0 + pitch_variance)
	var audio_item: AudioItem = AudioItem.new()
	audio_item.stream = stream
	audio_item.pitch_scale = pitch_scale
	_enqueue_audio_item(audio_item)


#############
## helpers ##
#############


func _enqueue_audio_item(audio_item: AudioItem) -> void:
	if _available_stream_players.size() > 0:
		var stream_player: AudioStreamPlayer = _available_stream_players.pop_front()
		_play_audio_item(stream_player, audio_item)
	else:
		_audio_queue.push_back(audio_item)


func _play_audio_item(stream_player: AudioStreamPlayer, audio_item: AudioItem) -> void:
	stream_player.stream = audio_item.stream
	stream_player.pitch_scale = audio_item.pitch_scale
	stream_player.play()


#############
## signals ##
#############


func _on_stream_player_finished(stream_player: AudioStreamPlayer) -> void:
	stream_player.pitch_scale = 1.0
	if _audio_queue.size() > 0:
		var audio_item: AudioItem = _audio_queue.pop_front()
		_play_audio_item(stream_player, audio_item)
	else:
		_available_stream_players.append(stream_player)
