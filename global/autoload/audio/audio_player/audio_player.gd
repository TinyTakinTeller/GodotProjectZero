class_name AudioPlayer extends Node

signal finished
signal master_volume_changed(volume: float)

const TWEEN_FADE_AUDIO_DURATION: float = 2.0

@export_enum(&"Master", &"Music", &"SFX") var default_bus: String = &"Music"
@export var default_audio: Resource  # AudioStream | Song, can't union type in gdscript :(
@export var autoplay: bool = false
@export var max_volume_idle: float = 1.0
@export var max_volume_combat: float = 1.0
@export var is_looping: bool = false

var master_volume: float = _idle_playback_position

var _current_audio: Resource
var _fade_tween: Tween
var _idle_playback_position: float = 0.0
var _combat_playback_position: float = 0.0

@onready var states: StateMachine = %States
@onready var tracks: Node = %Tracks
@onready var idle_track: AudioStreamPlayer = %Idle
@onready var combat_track: AudioStreamPlayer = %Combat

###############
## overrides ##
###############


func _ready() -> void:
	assert(default_audio is AudioStream || default_audio is Song)

	set_bus(default_bus)
	set_audio(default_audio)
	_connect_signals()


#############
## methods ##
#############

func get_max_volume() -> float:
	if states.current.name == "Combat":
		return max_volume_combat
	return max_volume_idle

func set_bus(bus: StringName) -> void:
	idle_track.bus = bus
	combat_track.bus = bus


func set_audio(audio: Resource) -> void:
	_current_audio = audio
	if audio is AudioStream:
		idle_track.stream = audio
	if audio is Song:
		idle_track.stream = audio.idle_audio_stream
		combat_track.stream = audio.combat_audio_stream


func is_playing() -> bool:
	return idle_track.playing || combat_track.playing


func play(restart: bool = true) -> void:
	if restart:
		_idle_playback_position = 0.0
		_combat_playback_position = 0.0
	idle_track.play(_idle_playback_position)
	combat_track.play(_combat_playback_position)


func stop() -> void:
	idle_track.stop()
	combat_track.stop()


func set_master_volume(volume_db: float) -> void:
	master_volume = volume_db
	master_volume_changed.emit(master_volume)


func transition_master_volume(from_volume: float, to_volume: float) -> void:
	if _fade_tween != null:
		_fade_tween.kill()
	_fade_tween = create_tween()

	_fade_tween.tween_method(set_master_volume, from_volume, to_volume, TWEEN_FADE_AUDIO_DURATION)


func _fade_out_callback(pause: bool) -> void:
	if pause:
		_idle_playback_position = idle_track.get_playback_position()
		_combat_playback_position = combat_track.get_playback_position()
		stop()


func fade_out(pause: bool = true) -> void:
	var from_volume: float = get_max_volume()
	var to_volume: float = 0.0
	transition_master_volume(from_volume, to_volume)
	_fade_tween.tween_callback(_fade_out_callback.bind(pause))


func fade_in(restart: bool = false) -> void:
	var from_volume: float = 0.0
	var to_volume: float = get_max_volume()
	transition_master_volume(from_volume, to_volume)
	play(restart)


###############
## signals ##
###############


func _connect_signals() -> void:
	SignalBus.tab_changed.connect(_on_tab_changed)
	idle_track.finished.connect(_on_track_finished)
	combat_track.finished.connect(_on_track_finished)


func _on_track_finished() -> void:
	if is_looping:
		play(0.0)
	else:
		stop()
		finished.emit()


func _on_tab_changed(tab_data: TabData) -> void:
	if _current_audio is Song:
		if tab_data.id == DarknessScreen.TAB_DATA_ID:
			states.transition_to("Combat")
		elif states.current.name == "Combat" && !tab_data.id == StarwayScreen.TAB_DATA_ID:
			states.transition_to("Idle")
