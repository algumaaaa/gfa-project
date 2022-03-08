extends KinematicBody

var rotframe = 0
var h_mov = Vector3()
var direction = Vector3()
var movement = Vector3()
var speed = 1
var gravity = 50
var gravity_vec = Vector3()
var blooddir = floor(rand_range(1, 8))
onready var animplay = $AnimationPlayer
export var framepass = false
onready var giblet = preload("res://giblet.tscn")
onready var blooddroplet = preload("res://blooddroplet.tscn")
onready var bloodpud = preload("res://bloodpuddle.tscn")
onready var sprite = $Sprite3D
onready var raycontainer = $raycont
onready var rayfloor = $rayfloor

func _physics_process(delta):
	if !is_on_floor():
		gravity_vec += Vector3.DOWN * gravity * delta
		h_mov = h_mov.linear_interpolate(direction * speed, delta)
		movement.z = h_mov.z + gravity_vec.z
		movement.x = h_mov.x + gravity_vec.x
		movement.y = gravity_vec.y
		move_and_slide(movement, Vector3.UP)
	elif is_on_floor():
		queue_free()

	if blooddir == 1:
		direction -= transform.basis.z
	elif blooddir == 2:
		direction += transform.basis.z
	elif blooddir == 3:
		direction -= transform.basis.x
	elif blooddir == 4:
		direction += transform.basis.x
	elif blooddir == 5:
		direction -= transform.basis.z
		direction += transform.basis.x
	elif blooddir == 6:
		direction += transform.basis.z
		direction -= transform.basis.x
	elif blooddir == 7:
		direction -= transform.basis.x
		direction -= transform.basis.z
	elif blooddir == 8:
		direction += transform.basis.x
		direction += transform.basis.z

	animplay.play("idle", gravity_vec.y)

#	if framepass:
#		var bd = blooddroplet.instance()
#		self.get_parent().add_child(bd)
#		bd.global_transform.origin = self.global_transform.origin
#		framepass = false

	if rayfloor.is_colliding():
		animplay.stop()
		var target = rayfloor.get_collider()
#		if target != null:
		if !target.is_in_group("enemies") and blooddir > 4:
			var bpd = bloodpud.instance()
			bpd.onfloor = true
#			target.add_child(bpd)
#			bpd.global_transform.origin = rayfloor.get_collision_point()
#			bpd.look_at(rayfloor.get_collision_point() + rayfloor.get_collision_normal(), Vector3.UP)
			makebh(target, rayfloor, bpd)
			queue_free()

	for r in raycontainer.get_children():
		var target = r.get_collider()
#		if target != null:
		if target != null and target.is_in_group("player"):
			target.bloody += 1
			queue_free()
		if target != null and !target.is_in_group("enemies") and !target.is_in_group("player"):
			var bpd = bloodpud.instance()
			bpd.onfloor = false
#			target.add_child(bpd)
#			bpd.global_transform.origin = r.get_collision_point()
#			bpd.look_at(r.get_collision_point() + r.get_collision_normal(), Vector3.UP)
			makebh(target, r, bpd)
			queue_free()

func _ready():
	set_as_toplevel(true)
	gravity_vec = Vector3.UP * rand_range(5, 15)
	if blooddir <= 2:
		sprite.frame_coords = Vector2(3, 0)
	elif blooddir == 3:
		sprite.frame_coords = Vector2(3, 1)
	elif blooddir == 4:
		sprite.frame_coords = Vector2(4, 1)


func _on_Timer_timeout():
		var bd = blooddroplet.instance()
		self.add_child(bd)
		bd.global_transform.origin = self.global_transform.origin
		if rotframe == 0:
			sprite.rotation_degrees = Vector3(0, 0, 0)
		if rotframe == 1:
			sprite.rotation_degrees = Vector3(30, 0, 30)
		if rotframe == 2:
			sprite.rotation_degrees = Vector3(-30, 0, -30)
		rotframe += 1
		if rotframe == 3: rotframe == 0

func makebh(var t, var r, var bh):
	t.add_child(bh)
	if r.get_collision_normal().normalized() == Vector3.UP:
		bh.global_transform.origin = r.get_collision_point() + r.get_collision_normal().normalized() * 0.001
		bh.rotation_degrees.x = 90
	elif r.get_collision_normal().normalized() == Vector3.DOWN:
		bh.global_transform.origin = r.get_collision_point() + r.get_collision_normal().normalized() * 0.001
		bh.rotation_degrees.x = -90
	else:
		bh.look_at_from_position(r.get_collision_point(), r.get_collision_point() + r.get_collision_normal().normalized(), Vector3.UP)
