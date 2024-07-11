extends Node

@export var default_sfx_pitch_variance: float = 0.5:
	set(value):
		default_sfx_pitch_variance = clampf(value, 0.0, 1.0)

var _track: int = 0

@onready var sfx_queue: AudioQueue = %SfxQueue
@onready var sfx_map: Node = %SfxMap
@onready var music_tracks: Node = %MusicTracks

###############
## overrides ##
###############


func _ready() -> void:
	_initalize()
	_connect_signals()


#############
## helpers ##
#############


func _initalize() -> void:
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
	if _track == track:
		return

	var music_track_next: MusicTrack = music_tracks.get_child(track)
	var music_track_previous: MusicTrack = music_tracks.get_child(_track)
	_track = track

	music_track_previous.fade_out()
	music_track_next.fade_in()
	if song_stream != null:
		music_track_next.swap(song_stream)


func play_sfx(
	id: String, sfx_stream: AudioStream, pitch_variance: float = default_sfx_pitch_variance
) -> void:
	sfx_queue.play(id, sfx_stream, pitch_variance)


func play_sfx_id(sfx_id: String, pitch_variance: float = default_sfx_pitch_variance) -> void:
	var sfx_stream: AudioStream = sfx_map.SFX_ID.get(sfx_id, null)
	if sfx_stream:
		play_sfx(sfx_id, sfx_stream, pitch_variance)


func stop_sfx_id(sfx_id: String) -> void:
	sfx_queue.stop(sfx_id)


###############
## signals ##
###############


func _connect_signals() -> void:
	SignalBus.tab_changed.connect(_on_tab_changed)


func _on_tab_changed(tab_data: TabData) -> void:
	# if tab_data.id == DarknessScreen.TAB_DATA_ID:
	# 	Audio.swap_crossfade_music(1)
	# else:
	Audio.swap_crossfade_music(0)
