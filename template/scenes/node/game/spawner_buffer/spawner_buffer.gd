# see example usage in [GameButton] where [LabelParticleTween] or [LabelParticleEmitter] is used
class_name SpawnerBuffer
extends Node
## Spawns [entity_pck] scene instances or if there is no room buffers them until there is room.
## [br][br]
## Original File MIT License Copyright (c) 2024 TinyTakinTeller

@export var entity_pck: PackedScene
## Should process arguments before scene is spawned or while it is buffered.
@export var entity_buffer_callable: String = "buffer"
## Will be called when scene is spawned with no arguments.
@export var entity_flush_callable: String = "flush"
## Should trigger when scene is finished and ready for removal.
@export var entity_finished_signal: String = "finished"
## New scenes will attach to given parent scene.
@export var entity_parent: Node
## New scene will be buffered instead spawned if max count is reached.
@export var max_count: int = 10
## Helps prevent reaching max count in a short burst of time.
@export var delay_time: float = 0.1:
	set(value):
		delay_time = value
		if is_inside_tree():
			timer.wait_time = delay_time

var _count: int = 0:
	set(value):
		_count = value
		# LogWrapper.debug(self, "Entity count: ", _count)
var _entity_buffer: Node = null

@onready var timer: Timer = %Timer


func _ready() -> void:
	timer.wait_time = delay_time


## Process next set of arguments, either passing them to a new spawned entity or to buffered entity.
func process(arguments: Array) -> void:
	buffer(arguments)
	if _count < max_count and timer.is_stopped():
		flush()


## Passes arguments to the bufferd entity or to a new entity.
func buffer(arguments: Array) -> void:
	if _entity_buffer == null:
		_entity_buffer = _instantiate()
	_entity_buffer.callv(entity_buffer_callable, arguments)


## Spawns entity from the buffer.
func flush() -> void:
	if _entity_buffer != null:
		entity_parent.add_child(_entity_buffer)
		_entity_buffer.call(entity_flush_callable)
		_entity_buffer = null
		_count += 1

		if delay_time > 0:
			timer.start()


func _instantiate() -> Node:
	var entity: Node = entity_pck.instantiate()
	entity.connect(entity_finished_signal, _on_entity_finished.bind(entity))
	return entity


func _destroy(entity: Node) -> void:
	entity.queue_free.call_deferred()
	_count -= 1
	flush()


func _on_entity_finished(entity: Node) -> void:
	_destroy(entity)
