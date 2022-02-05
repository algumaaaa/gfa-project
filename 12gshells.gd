extends RigidBody

var speed = rand_range(5, 10)
var bullettype = 1
onready var sprite3d = $Sprite3D

func _physics_process(delta):
	pass

func _ready():
	if bullettype == 1:
		sprite3d.frame = 2
		sprite3d.scale = Vector3(0.5, 0.5, 0.5)
	elif bullettype == 2:
		sprite3d.frame = 1
		sprite3d.scale = Vector3(1, 1, 1)
	elif bullettype == 3:
		sprite3d.frame = 2
		sprite3d.scale = Vector3(0.7, 0.7, 0.7)
	elif bullettype == 4:
		sprite3d.frame = 8
		sprite3d.scale = Vector3(1, 1, 1)
	set_as_toplevel(true)
	if bullettype != 3:
		apply_impulse(-transform.basis.y, transform.basis.y * speed)
		apply_impulse(-transform.basis.x, transform.basis.x * speed)
	else:
		apply_impulse(-transform.basis.y, transform.basis.y * speed)
		apply_impulse(transform.basis.x, -transform.basis.x * speed)

func _on_Timer_timeout():
	queue_free()
