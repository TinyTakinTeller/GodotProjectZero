extends Node

@export var songs: Array[Song] = []

@onready var tracks: Node = %Tracks
@onready var states: StateMachine = %States

@onready var idle_track: AudioStreamPlayer = %Idle
@onready var combat_track: AudioStreamPlayer = %Combat

var next_song_index: int = 0


func _ready() -> void:
	play_next_song()
	SignalBus.tab_changed.connect(_on_tab_changed)
	idle_track.finished.connect(_on_song_finished)
	combat_track.finished.connect(_on_song_finished)


func play_next_song() -> void:
	play_song(songs[next_song_index])
	next_song_index += 1
	if next_song_index >= len(songs):
		next_song_index = 0


func play_song(song: Song) -> void:
	print("playing song %s" % str(song.idle_audio_stream))
	idle_track.stream = song.idle_audio_stream
	combat_track.stream = song.combat_audio_stream
	idle_track.play()
	combat_track.play()


func _on_tab_changed(tab_data: TabData) -> void:
	if tab_data.id == "enemy":
		states.transition_to("Combat")
	elif states.current_state.name == "Combat":
		states.transition_to("Idle")


func _on_song_finished() -> void:
	play_next_song()
