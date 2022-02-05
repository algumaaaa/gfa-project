extends RigidBody

var shoot = false

onready var explosion = preload("res://explosion.tscn")

const speed = 10

func _physics_process(delta):
	if shoot:
		apply_impulse(transform.basis.z, -transform.basis.z * speed)

func _ready():
	set_as_toplevel(true)

func _on_Area_body_entered(body):
	var e = explosion.instance()
	self.get_parent().add_child(e)
	e.set_as_toplevel(true)
	e.global_transform.origin = self.global_transform.origin
	queue_free()
