class_name MusicTrack extends Node

const TWEEN_FADE_AUDIO_DURATION: float = 2.0

@export_enum(&"Master", &"Music", &"SFX") var bus: String = &"Music"
@export var audio_stream: AudioStream
@export var autoplay: bool = false
@export var max_volume: float = 1.0

var _playback_position: float = 0.0
var _audio_stream_player_tween: Tween

@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer

###############
## overrides ##
###############


func _ready() -> void:
	audio_stream_player.bus = bus
	audio_stream_player.stream = audio_stream
	if autoplay:
		audio_stream_player.play()


#############
## methods ##
#############


func swap(song_stream: AudioStream) -> void:
	audio_stream_player.stream = song_stream
	audio_stream_player.play()


func fade_out(pause: bool = true) -> void:
	audio_stream_player.volume_db = linear_to_db(max_volume)

	if _audio_stream_player_tween != null:
		_audio_stream_player_tween.kill()
	_audio_stream_player_tween = create_tween()

	_audio_stream_player_tween.tween_method(
		_tween_fade_audio.bind(audio_stream_player), max_volume, 0.0, TWEEN_FADE_AUDIO_DURATION
	)
	_audio_stream_player_tween.tween_callback(_fade_out_callback.bind(pause))


func fade_in(restart: bool = false) -> void:
	audio_stream_player.volume_db = linear_to_db(0.0)
	if restart:
		_playback_position = 0.0
		audio_stream_player.stop()

	if _audio_stream_player_tween != null:
		_audio_stream_player_tween.kill()
	_audio_stream_player_tween = create_tween()

	_audio_stream_player_tween.tween_method(
		_tween_fade_audio.bind(audio_stream_player), 0.0, max_volume, TWEEN_FADE_AUDIO_DURATION
	)


############
## tweens ##
############


func _tween_fade_audio(volume: float, song: AudioStreamPlayer) -> void:
	song.volume_db = linear_to_db(volume)
	if !audio_stream_player.playing:
		audio_stream_player.play(_playback_position)


func _fade_out_callback(pause: bool) -> void:
	if pause:
		_playback_position = audio_stream_player.get_playback_position()
		audio_stream_player.stop()
