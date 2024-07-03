extends Node

@export var default_sfx_pitch_variance: float = 0.5:
	set(value):
		default_sfx_pitch_variance = clampf(value, 0.0, 1.0)

var _track: int = 0

@onready var audio_queue: AudioQueue = %AudioQueue
@onready var music_tracks: Node = %MusicTracks

###############
## overrides ##
###############


func _ready() -> void:
	music_tracks.get_child(_track).fade_in()


#############
## methods ##
#############


func swap_crossfade_music_next() -> void:
	var track: int = (_track + 1) % music_tracks.get_child_count()
	swap_crossfade_music_new(track, null)


func swap_crossfade_music(track: int) -> void:
	swap_crossfade_music_new(track, null)


func swap_crossfade_music_new(track: int, song_stream: AudioStream) -> void:
	var music_track_next: MusicTrack = music_tracks.get_child(track)
	var music_track_previous: MusicTrack = music_tracks.get_child(_track)
	_track = track

	music_track_previous.fade_out()
	music_track_next.fade_in()
	if song_stream != null:
		music_track_next.swap(song_stream)


func play_sfx(sfx_stream: AudioStream, pitch_variance: float = default_sfx_pitch_variance) -> void:
	audio_queue.play(sfx_stream, pitch_variance)
