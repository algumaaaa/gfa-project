extends KinematicBody

var gravity = 50
var gravity_vec = Vector3()
var bsprite = floor(rand_range(1, 3))
onready var animplay = $AnimationPlayer
onready var sprite = $Sprite3D
onready var bloodpud = preload("res://bloodpuddle.tscn")

func _process(delta):
	var colinfo = move_and_collide(gravity_vec * delta)
	if colinfo:
		if bsprite > 1:
			var bpd = bloodpud.instance()
			bpd.onfloor = true
			colinfo.collider.add_child(bpd)
			bpd.global_transform.origin = self.global_transform.origin
			bpd.rotation_degrees.x = 90
#			bpd.look_at(colinfo.normal + colinfo.position, Vector3.UP)

			bpd.scale = Vector3(0.5, 0.5, 0.5)
		queue_free()

	if !is_on_floor():
		gravity_vec += Vector3.DOWN * gravity * delta
		move_and_slide(gravity_vec, Vector3.UP)

func _ready():
	set_as_toplevel(true)
	animplay.play("idle", gravity_vec.y)
	if bsprite == 1:
		sprite.frame_coords = Vector2(3, 0)
	elif bsprite == 2:
		sprite.frame_coords = Vector2(3, 1)
	elif bsprite == 3:
		sprite.frame_coords = Vector2(4, 1)

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
