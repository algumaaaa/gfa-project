extends RigidBody

var pickupable = false
var ammoAmount = null
var ammoType = null
var shot = false
var speed = 4

func _ready():
	set_as_toplevel(true)

func _physics_process(delta):
	if shot:
		apply_impulse(transform.basis.z, -transform.basis.z * speed)

	if ammoType == 0:
		$Sprite3D.frame = 0
	if ammoType == 1:
		$Sprite3D.frame = 1
	if ammoType == 2:
		$Sprite3D.frame = 0
	if ammoType == 3:
		$Sprite3D.frame = 3
	if ammoType == 4:
		$Sprite3D.frame = 2

func _on_Area_body_entered(body):
	if body.is_in_group("player") and pickupable:
		if ammoType == 0:
			body.nelevenammo += ammoAmount
		if ammoType == 1:
			body.doublebammo += ammoAmount
		if ammoType == 2:
			body.mac10ammo += ammoAmount
		if ammoType == 3:
			body.lactionammo += ammoAmount
		if ammoType == 4:
			body.glauncherammo += ammoAmount
		body.ammoAudio.play()
		body.ammoPickedUp = true
		queue_free()


func _on_Timer_timeout():
	if speed > 0:
		speed -= 4
	pickupable = true
