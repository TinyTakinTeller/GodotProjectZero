class_name AudioQueue extends Node

@export var stream_player_count: int = 4
@export_enum(&"Master", &"Music", &"SFX") var bus: String = &"Master"

var available_stream_players: Array[AudioStreamPlayer] = []
var audio_queue: Array[Dictionary] = []


func _ready() -> void:
	for i in stream_player_count:
		var stream_player: AudioStreamPlayer = AudioStreamPlayer.new()
		add_child(stream_player)
		stream_player.finished.connect(_on_stream_player_finished.bind(stream_player))
		available_stream_players.append(stream_player)


func _on_stream_player_finished(stream_player: AudioStreamPlayer) -> void:
	stream_player.pitch_scale = 1.0
	available_stream_players.append(stream_player)


func play(stream: AudioStream, pitch_variance: float) -> void:
	var pitch_scale: float = randf_range(1.0 - pitch_variance, 1.0 + pitch_variance)
	audio_queue.append({"stream": stream, "pitch_scale": pitch_scale})


func _process(_delta: float) -> void:
	if not audio_queue.is_empty() and not available_stream_players.is_empty():
		var stream_player: AudioStreamPlayer = available_stream_players.pop_front()
		var sound: Dictionary = audio_queue.pop_front()

		stream_player.stream = sound.get("stream")
		stream_player.pitch_scale = sound.get("pitch_scale")
		stream_player.play()
