extends KinematicBody

var gibbed = false
var vh = 0
var hh = 0
var h_mov = Vector3()
var direction = Vector3()
var movement = Vector3()
var speed = 1
var gravity = 100
var gravity_vec = Vector3()
var blooddir = floor(rand_range(1, 8))
onready var animplay = $AnimationPlayer
export var framepass = false

onready var blooddroplet = preload("res://blooddroplet.tscn")
onready var bloodpud = preload("res://bloodpuddle.tscn")
onready var giblet = preload("res://giblet.tscn")

onready var sprite = $Sprite3D

func _process(delta):
	if !is_on_floor():
		gravity_vec += Vector3.DOWN * gravity * delta
		h_mov = h_mov.linear_interpolate(direction * speed, delta)
		movement.z = h_mov.z + gravity_vec.z
		movement.x = h_mov.x + gravity_vec.x
		movement.y = gravity_vec.y
		move_and_slide(movement, Vector3.UP)
		
		animplay.play("idle")
		if framepass:
			if blooddir > 4:
				vh += 1
				if vh > 4: vh = 0
			if blooddir <= 4:
				vh -= 1
				if vh < 0: vh = 4
			sprite.frame_coords = Vector2(hh, vh)
			if gibbed:
				var bd = giblet.instance()
				self.get_parent().add_child(bd)
				bd.global_transform.origin = self.global_transform.origin
			else:
				var bd = blooddroplet.instance()
				self.get_parent().add_child(bd)
				bd.global_transform.origin = self.global_transform.origin
			framepass = false
	elif is_on_floor():
		gravity_vec = -get_floor_normal() * gravity
		animplay.stop(false)

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

func _ready():
	set_as_toplevel(true)
	gravity_vec = Vector3.UP * rand_range(30, 40)


func _on_Timer_timeout():
	get_parent().queue_free()
	queue_free()
