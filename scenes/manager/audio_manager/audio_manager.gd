class_name AudioManager extends Node

# @onready var music: Node = %Music
@onready var audio_queue: AudioQueue = %AudioQueue
@onready var sound_tracks: Node = %SoundTracks

@export var pitch_shift: float = 0.5

var current_song: AudioStreamPlayer

var song_index := 0
var songs: Array[AudioStream] = [
	preload("res://assets/audio/sfx/ambience/dark_ambient_1.wav"),
]


func _ready() -> void:
	_on_song_finished()


func _on_song_finished() -> void:
	play_music(songs[song_index])
	song_index += 1
	if song_index == songs.size():
		song_index = 0


func _create_audio_stream_player(group: Node) -> void:
	var audio_stream_player: AudioStreamPlayer = AudioStreamPlayer.new()
	group.add_child(group)
	audio_stream_player.finished.connect(audio_stream_player.queue_free)


func play_music(song_stream: AudioStream) -> void:
	if current_song:
		var current_song_tween := create_tween()
		current_song_tween.finished.connect(current_song.queue_free)
		current_song_tween.tween_property(current_song, "volume_db", -100, 5.0)

	var next_song := AudioStreamPlayer.new()
	next_song.stream = song_stream
	next_song.volume_db = -100
	next_song.bus = "Music"

	var next_song_tween := create_tween()
	next_song_tween.tween_property(next_song, "volume_db", 0, 1.0)

	sound_tracks.add_child(next_song)
	next_song.play()
	current_song = next_song
	current_song.finished.connect(_on_song_finished)


func play_sfx(sfx_stream: AudioStream, pitch_variance: float = 0.0) -> void:
	audio_queue.play(sfx_stream, pitch_variance)
