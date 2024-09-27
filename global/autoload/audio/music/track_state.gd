extends StateMachineState

@onready var music: Node = owner

var track: AudioStreamPlayer


func _on_ready() -> void:
	await music.ready
	track = music.tracks.get_node(NodePath(self.name))


func _on_state_enter() -> void:
	print("ENTERING %s" % self.name)
	track.volume_db = linear_to_db(1.0)


func _on_state_exit() -> void:
	track.volume_db = linear_to_db(0.0)
