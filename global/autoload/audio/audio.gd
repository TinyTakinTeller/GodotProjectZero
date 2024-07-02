class_name AudioManager extends Node

# @onready var music: Node = %Music
@onready var audio_queue: AudioQueue = %AudioQueue
@onready var music_tracks: Node = %MusicTracks
@onready var current_song: AudioStreamPlayer = %MusicTracks.get_child(0)

@export var default_pitch_variance: float = 0.5:
	set(value):
		default_pitch_variance = clampf(value, 0.0, 1.0)


func _on_song_finished() -> void:
	pass


func play_music(song_stream: AudioStream) -> void:
	if current_song:
		var current_song_tween := create_tween()
		current_song_tween.finished.connect(current_song.queue_free)
		current_song_tween.tween_property(current_song, "volume_db", -100, 2.0)

	var next_song := AudioStreamPlayer.new()
	next_song.stream = song_stream
	next_song.volume_db = -100
	next_song.bus = &"Music"

	var next_song_tween := create_tween()
	next_song_tween.tween_property(next_song, "volume_db", 0, 2.0)

	music_tracks.add_child(next_song)
	next_song.play()
	current_song = next_song
	current_song.finished.connect(_on_song_finished)


func play_sfx(sfx_stream: AudioStream, pitch_variance: float = default_pitch_variance) -> void:
	audio_queue.play(sfx_stream, pitch_variance)
