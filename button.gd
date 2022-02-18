extends Spatial

export var value = 1
var interact = false
signal toggled(value)

func _physics_process(delta):
	if interact:
		emit_signal("toggled", value)
		interact = false
