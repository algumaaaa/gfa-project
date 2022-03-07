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

onready var biteSound = preload("res://Audio/Enemies/Worm/Bite.wav")
onready var enemAudio = $AudioStreamPlayer3D

onready var navnode = get_parent()
onready var player = get_tree().get_root().get_node("/root/Spatial/player/")
onready var ray = $RayCast
onready var lookat = $lookat
onready var detect = $detect

onready var damagezone = $damagezone
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
			add_to_group("alertEnemies")
			navnode.navstate = navnode.ALERT
			if !animplay.is_playing():
				animplay.play("walk")
			if !Vector3.UP.cross(navnode.navdir - global_transform.origin) == Vector3():
				lookat.look_at(navnode.navdir, Vector3.UP)
			rotate_y(deg2rad(lookat.rotation.y * 10))

		AI.PATHING:
			navnode.navstate = navnode.PATHING
			if !animplay.is_playing():
				animplay.play("walk")
			if !Vector3.UP.cross(navnode.navdir - global_transform.origin) == Vector3():
				lookat.look_at(navnode.navdir, Vector3.UP)
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
			if self.is_in_group("alertEnemies"):
				remove_from_group("alertEnemies")
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
			enemAudio.stream = biteSound
			enemAudio.max_db = -6
			enemAudio.play()
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
