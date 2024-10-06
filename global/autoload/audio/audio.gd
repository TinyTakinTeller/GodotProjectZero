extends Node

@export var default_sfx_pitch_variance: float = 0.5:
	set(value):
		default_sfx_pitch_variance = clampf(value, 0.0, 1.0)

var _track: int = 0
var _current_audio_player: AudioPlayer

@onready var sfx_queue: AudioQueue = %SfxQueue
@onready var sfx_map: Node = %SfxMap

@onready var music_tracks: Node = %Music

@onready var heartbeat_ambience: AudioPlayer = %Heartbeat

###############
## overrides ##
###############


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("swap_music_next"):
		swap_crossfade_music_next()


func _ready() -> void:
	_initalize()
	_connect_signals()
	for audio_player: AudioPlayer in music_tracks.get_children():
		audio_player.finished.connect(_on_music_track_finished)


#############
## helpers ##
#############


func _initalize() -> void:
	_track = randi() % music_tracks.get_child_count()
	_current_audio_player = music_tracks.get_child(_track)
	_current_audio_player.fade_in()


#############
## methods ##
#############


func swap_crossfade_music_next() -> void:
	_track = (_track + 1) % music_tracks.get_child_count()
	swap_crossfade_audio(music_tracks.get_child(_track))
	if Game.PARAMS_DEBUG["debug_logs"]:
		prints("track", _track)


func swap_crossfade_audio(audio_player: AudioPlayer) -> void:
	if _current_audio_player == audio_player:
		return

	_current_audio_player.fade_out()
	_current_audio_player = audio_player
	_current_audio_player.fade_in()


func play_sfx(
	id: String,
	sfx_stream: AudioStream,
	pitch_variance: float = default_sfx_pitch_variance,
	volume: float = 1.0
) -> void:
	sfx_queue.play(id, sfx_stream, pitch_variance, volume)


func play_sfx_id(
	sfx_id: String, pitch_variance: float = default_sfx_pitch_variance, volume: float = 1.0
) -> void:
	var sfx_stream: AudioStream = sfx_map.SFX_ID.get(sfx_id, null)
	if sfx_stream:
		play_sfx(sfx_id, sfx_stream, pitch_variance, volume)


func stop_sfx_id(sfx_id: String) -> void:
	sfx_queue.stop(sfx_id)


###############
## signals ##
###############


func _connect_signals() -> void:
	SignalBus.tab_changed.connect(_on_tab_changed)
	SignalBus.heart_click.connect(_on_heart_click)
	SignalBus.heart_unclick.connect(_on_heart_unclick)
	SignalBus.prestige_condition_pass.connect(_on_prestige_condition_pass)
	SignalBus.soul.connect(_on_soul)
	SignalBus.boss_start.connect(_on_boss_start)
	SignalBus.boss_end.connect(_on_boss_end)


func _on_tab_changed(tab_data: TabData) -> void:
	if tab_data.id == StarwayScreen.TAB_DATA_ID:
		swap_crossfade_audio(heartbeat_ambience)
	elif tab_data.id == "unknown":
		_current_audio_player.fade_out()
	else:
		var music_player: AudioPlayer = music_tracks.get_child(_track)
		swap_crossfade_audio(music_player)


func _on_music_track_finished() -> void:
	swap_crossfade_music_next()


func _on_heart_click() -> void:
	heartbeat_ambience.idle_track.pitch_scale = 2.0


func _on_heart_unclick() -> void:
	heartbeat_ambience.idle_track.pitch_scale = 1.0


func _on_prestige_condition_pass(_infinity_count: int) -> void:
	_current_audio_player.fade_out()


func _on_soul() -> void:
	_current_audio_player.fade_out()


func _on_boss_start() -> void:
	pass ## TODO boss music sountrack


func _on_boss_end() -> void:
	_current_audio_player.fade_out()
