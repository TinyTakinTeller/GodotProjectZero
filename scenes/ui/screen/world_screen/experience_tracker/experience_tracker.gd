class_name ExperienceTracker
extends MarginContainer

@onready var experience_label: Label = %ExperienceLabel
@onready var updated_simple_tween: SimpleTween = %UpdatedSimpleTween

###############
## overrides ##
###############


func _ready() -> void:
	_initialize()
	_connect_signals()


###########
## setup ##
###########


func _initialize() -> void:
	var total: int = SaveFile.resources.get("experience", 0)
	_set_experience(total)


func _set_experience(total: int) -> void:
	experience_label.text = "Experience: " + NumberUtils.format_number(total)


#############
## signals ##
#############


func _on_resource_updated(id: String, total: int, _amount: int, _source_id: String) -> void:
	if id == "experience":
		_set_experience(total)
		updated_simple_tween.play_animation()


func _connect_signals() -> void:
	SignalBus.resource_updated.connect(_on_resource_updated)


############
## export ##
############


func _updated_simple_tween_method(animation_percent: float) -> void:
	self.modulate.r = animation_percent
	self.modulate.g = animation_percent
