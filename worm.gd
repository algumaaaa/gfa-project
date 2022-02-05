extends KinematicBody

var health = 100
var damagequeue = 0
var tookdamage = false
var aistate = AI.IDLE
var alert = false
export var exploded = false
export var damageframe = false

var speed = 30
var path = []
var currentpathindex = 0
var randompath = Vector3()
var ispathing = false

onready var navnode = get_parent()
onready var player = get_tree().get_root().get_node("/root/Spatial/player/")
onready var ray = $RayCast
onready var lookat = $lookat
onready var detect = $detect

onready var damagezone = $damagezone
onready var tick = $Timer
onready var area = $Area
onready var hitbox = $CollisionShape
onready var despawn = $despawn
onready var animplay = $sprite/AnimationPlayer
onready var sprite3d = $sprite
onready var camera = get_tree().get_root().get_node("/root/Spatial/player/head/Camera")
export var animframe = 0
onready var gore = preload("res://gore.tscn")
onready var blood = preload("res://blood.tscn")

enum AI{
	IDLE,
	ALERT,
	PATHING,
	ATTACK,
	PAIN,
	DIE,
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
			navnode.navstate = navnode.STOPPED

		AI.ALERT:
			navnode.navstate = navnode.ALERT
			if !animplay.is_playing():
				animplay.play("walk")
			lookat.look_at(navnode.navdir, Vector3.UP)
			rotate_y(deg2rad(lookat.rotation.y * 10))

		AI.PATHING:
			navnode.navstate = navnode.PATHING
			if !animplay.is_playing():
				animplay.play("walk")
			lookat.look_at(randompath, Vector3.UP)
			rotate_y(deg2rad(lookat.rotation.y * 10))

		AI.PAIN:
			navnode.navstate = navnode.STOPPED
			animplay.play("pain")
			alert = true
			damagequeue = 0

		AI.ATTACK:
			navnode.navstate = navnode.STOPPED
			if tookdamage == false and aistate != AI.DIE:
				animplay.play("attack")

		AI.DIE:
			navnode.navstate = navnode.STOPPED
			if despawn.is_stopped():
				animplay.play("death")
				despawn.start()
			ray.enabled = false
			hitbox.disabled = true
			navnode.hitbox.disabled = true
			navnode.tick.stop()

		AI.GIB:
			navnode.navstate = navnode.STOPPED
			if despawn.is_stopped():
				for i in 5:
					var g = gore.instance()
					g.hh = i
					self.get_parent().add_child(g)
					g.global_transform.origin = self.global_transform.origin
					g.gibbed = true
				navnode.tick.stop()
				navnode.hitbox.disabled = true
				queue_free()

	if tookdamage == true:

		health -= damagequeue
		if health > 0:
			aistate = AI.PAIN
		if health <= 0:
			if damagequeue >= 150:
					aistate = AI.GIB
			else:
				aistate = AI.DIE

	if ray.is_colliding() and !tookdamage and aistate != AI.DIE and aistate != AI.GIB:
		var target = ray.get_collider()
		if target.is_in_group("player"):
			aistate = AI.ATTACK
		else:
			aistate = AI.PATHING
			ispathing = true

	if damageframe:
		var p = ray.get_collider()
		if p != null and p.is_in_group("player"):
			p.damagequeue += 10
		damageframe = false

	if exploded:
		for body in damagezone.get_overlapping_bodies():
			if body.is_in_group("player"):
				body.damagequeue += 25
			if body.is_in_group("enemies"):
				body.damagequeue += 50
				body.tookdamage = true
		var bld = blood.instance()
		self.add_child(bld)
		bld.global_transform.origin = self.global_transform.origin
		var bldd = blood.instance()
		self.add_child(bldd)
		bldd.global_transform.origin = self.global_transform.origin
		var blddd = blood.instance()
		self.add_child(blddd)
		blddd.global_transform.origin = self.global_transform.origin
		exploded = false

	detect.look_at(player.global_transform.origin, Vector3.UP)
	if detect and aistate == AI.IDLE:
		var p = detect.get_collider()
		if p != null:
			if p.is_in_group("player"):
				animplay.stop()
				aistate = AI.ALERT

#func get_target_path(target_pos):
#	if aistate == AI.ALERT:
#		path = nav.get_simple_path(global_transform.origin, target_pos)
#		currentpathindex = 0
#	if aistate == AI.PATHING:
#		path = nav.get_simple_path(global_transform.origin, target_pos)
#		currentpathindex = 0

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

	return random_pos_on_unit_sphere * rand_range (radius * 0.5, radius)

#func _on_Timer_timeout():
#	if aistate == AI.ALERT:
#		get_target_path(player.global_transform.origin)
#	if aistate == AI.PATHING:
#		if ispathing:
#			randompath = Vector3(player.global_transform.origin.x + get_random_pos_in_sphere(100).x,0,player.global_transform.origin.z + get_random_pos_in_sphere(100).z) + get_parent().global_transform.origin
#			get_target_path(randompath)
#			ispathing = false
#	if !ispathing and aistate != AI.IDLE:
#		aistate = AI.ALERT

func _on_Area_body_entered(body):
	if body.is_in_group("player") and aistate != AI.DIE and aistate != AI.GIB:
		aistate = AI.ALERT

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "attack":
		if damageframe:
			!damageframe
		aistate = AI.ALERT
	if anim_name == "pain":
		tookdamage = false
		if health > 0:
			aistate = AI.ALERT

func _on_despawn_timeout():
	queue_free()
