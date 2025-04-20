class_name LabelParticleTweenDamage
extends LabelParticleTween


func flush() -> void:
	self.text = "- %s %s" % [_format(label_amount), label_title]
	particle_tween.start()
