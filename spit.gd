extends RigidBody

var damage = 20
var shoot = false

onready var explosion = preload("res://explosion.tscn")

const speed = 5

func _physics_process(delta):
	if shoot:
		apply_impulse(transform.basis.z, -transform.basis.z * speed)

func _ready():
	set_as_toplevel(true)

func _on_Area_body_entered(body):
	if body.is_in_group("player"):
		body.damagequeue += damage
		queue_free()
