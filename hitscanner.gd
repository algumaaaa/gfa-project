extends KinematicBody

var health = 500
var damagequeue = 0
var tookdamage = false
var aistate = AI.IDLE
var alert = false
var ready = false

var speed = 10
var path = []
var currentpathindex = 0
var randompath = Vector3()
var ispathing = false

onready var nav = get_parent()
onready var player = get_tree().get_root().get_node("/root/Spatial/player/")
onready var ray = $RayCast
onready var lookat = $lookat

onready var tick = $Timer
onready var area = $Area
onready var hitbox = $CollisionShape
onready var despawn = $despawn
onready var animplay = $sprite/AnimationPlayer
onready var sprite3d = $sprite
onready var camera = get_tree().get_root().get_node("/root/Spatial/player/head/Camera")
export var animframe = 0
onready var gore = preload("res://gore.tscn")

enum AI{
	IDLE,
	ALERT,
	PATHING,
	ATTACK,
	PAIN,
	DIE,
	GORE,
	GIB
}

func _process(delta):
	if camera == null:
		return
	var player_foward = camera.global_transform.basis.z
	var foward = global_transform.basis.z
	var left = global_transform.basis.x

	var left_dot = left.dot(player_foward)
	var foward_dot = foward.dot(player_foward)
	var animrow = 0
	sprite3d.flip_h = true
	if foward_dot < -0.85:
		animrow = 0
	elif foward_dot > 0.85:
		animrow = 4
	else: 
		sprite3d.flip_h = left_dot < 0
		if abs(foward_dot) < 0.3:
			animrow = 2
		elif foward_dot < 0:
			animrow = 1
		else:
			animrow = 3
	sprite3d.frame_coords = Vector2(animframe, animrow)

func _physics_process(delta):

	if Input.is_action_just_pressed("debug0"):
		aistate = AI.GIB

	match aistate:
		AI.IDLE:
			animframe = 0
			animplay.stop()
		AI.ALERT:
			lookat.look_at(player.global_transform.origin, Vector3.UP)
			rotate_y(deg2rad(lookat.rotation.y * 50))
			if ray.is_colliding():
				var collider = ray.get_collider()
				if collider.is_in_group("player"):
					aistate = AI.ATTACK
			else:
				aistate = AI.PATHING
		AI.PATHING:
			ispathing = true
			if !animplay.is_playing():
				animplay.play("walk")
			lookat.look_at(randompath, Vector3.UP)
			rotate_y(deg2rad(lookat.rotation.y * 10))
			if currentpathindex < path.size():
				var direction = (path[currentpathindex] - global_transform.origin)
				if direction.length() < 1:
					currentpathindex += 1
				else:
					move_and_slide(direction.normalized() * speed, Vector3.UP)
		AI.PAIN:
			animplay.play("pain")
			alert = true
			ispathing = false
			damagequeue = 0

		AI.ATTACK:
			ispathing = false
			if ready == true:
				if tookdamage == false:
					animplay.play("attack")
			else:
				animplay.play("unsheathe")
		AI.DIE:
			if despawn.is_stopped():
				animplay.play("death")
				despawn.start()
			ray.enabled = false
			hitbox.disabled = true
			ispathing = false
			tick.stop()
		AI.GORE:
			if despawn.is_stopped():
				animplay.play("deathgore")
				var g = gore.instance()
				g.hh = 0
				self.add_child(g)
				g.global_transform.origin = self.global_transform.origin
				g.gibbed = false
				despawn.start()
			ray.enabled = false
			hitbox.disabled = true
			ispathing = false
			tick.stop()
		AI.GIB:
			if despawn.is_stopped():
				for i in 5:
					var g = gore.instance()
					g.hh = i
					self.get_parent().add_child(g)
					g.global_transform.origin = self.global_transform.origin
					g.gibbed = true
				queue_free()

	if tookdamage == true:

		health -= damagequeue
		if health > 0:
			aistate = AI.PAIN
		if health <= 0:
			if damagequeue > 100 and damagequeue < 150:
				var roll = rand_range(1, 2)
				if roll > 1.8:
					aistate = AI.GORE
				else: 
					aistate = AI.DIE
			elif damagequeue >= 150:
					aistate = AI.GIB
			else:
				aistate = AI.DIE

	ray.look_at(player.global_transform.origin, Vector3.UP)
	if ray.is_colliding() and !ispathing and !tookdamage:
		var collider = ray.get_collider()
		if collider.is_in_group("player"):
			ispathing = false
			aistate = AI.ATTACK

func get_target_path(target_pos):

	if aistate == AI.PATHING:
		path = nav.get_simple_path(global_transform.origin, target_pos)
		currentpathindex = 0

func get_random_pos_in_sphere (radius : float) -> Vector3:
	var x1 = rand_range (-1, 1)
	var x2 = rand_range (-1, 1)

	while x1*x1 + x2*x2 >= 1:
		x1 = rand_range(-1, 1)
		x2 = rand_range(-1, 1)

	var random_pos_on_unit_sphere = Vector3 (
	2 * x1 * sqrt(1 - x1*x1 - x2*x2),
	2 * x2 * sqrt(1 - x1*x1 - x2*x2),
	1 - 2 * (x1*x1 + x2*x2))

	return random_pos_on_unit_sphere * rand_range (0, radius)

func _on_Timer_timeout():
	if aistate == AI.PATHING:
		if ispathing:
			randompath = Vector3(player.global_transform.origin.x + get_random_pos_in_sphere(200).x,0,player.global_transform.origin.z + get_random_pos_in_sphere(200).z) + get_parent().global_transform.origin
			get_target_path(randompath)
			ispathing = false
	if !ispathing and aistate != AI.IDLE:
		aistate = AI.ALERT

func _on_Area_body_entered(body):
	if body.is_in_group("player") and aistate != AI.DIE and aistate != AI.GORE and aistate != AI.GIB:
		aistate = AI.ALERT

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "unsheathe":
		ready = true
		aistate = AI.ATTACK
	if anim_name == "attack":
		if ray.is_colliding():
			var target = ray.get_collider()
			if target.is_in_group("player"):
				aistate = AI.ATTACK
		else:
			animplay.play("sheathe")
	if anim_name == "sheathe":
		ready = false
		aistate = AI.ALERT
	if anim_name == "pain":
		ready = false
		tookdamage = false
		if health > 0:
			aistate = AI.ALERT

func _on_despawn_timeout():
	queue_free()
