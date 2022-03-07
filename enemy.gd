extends KinematicBody

var health = 100
var damagequeue = 0
var tookdamage = false
var aistate = AI.IDLE
var alert = false
export var damageframe = false
export var idlepathing = false

var timerdelay = 0
var speed = 25
var path = []
var currentpathindex = 0
var randompath = Vector3()
var ispathing = false

var punchSounds = []
onready var enemAudio = $enemAudio

onready var navnode = get_parent()
onready var player = get_tree().get_root().get_node("/root/Spatial/player/")
onready var ray = $RayCast
onready var lookat = $lookat
onready var detect = $detect

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

func _ready():
	randomize()

	punchSounds.append(preload("res://Audio/Enemies/Zombie/Punch1.wav"))
	punchSounds.append(preload("res://Audio/Enemies/Zombie/Punch2.wav"))
	punchSounds.append(preload("res://Audio/Enemies/Zombie/Punch3.wav"))

func _physics_process(delta):

	if Input.is_action_just_pressed("debug0"):
		aistate = AI.ALERT

	match aistate:

		AI.IDLE:
			if !idlepathing:
				animplay.stop()
				animframe = 0
				navnode.navstate = navnode.STOPPED
			else:
				navnode.navstate = navnode.IDLE
				if !animplay.is_playing() and navnode.currentpathindex != 0:
					animplay.play("swalk")
				elif navnode.currentpathindex >= navnode.path.size():
					animplay.stop()
				lookat.look_at(navnode.randompath, Vector3.UP)
				rotate_y(deg2rad(lookat.rotation.y * 10))

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

		AI.GORE:
			navnode.navstate = navnode.STOPPED
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

	if ray.is_colliding() and !tookdamage and aistate != AI.DIE and aistate != AI.GORE and aistate != AI.GIB and aistate != AI.IDLE:
		var target = ray.get_collider()
		if target.is_in_group("player"):
			target.slowed = true
			aistate = AI.ATTACK
		elif target.is_in_group("enemies"):
			aistate = AI.PATHING
			ispathing = true

	if damageframe:
		var p = ray.get_collider()
		if p != null and p.is_in_group("player"):
			p.damagequeue += 10
			enemAudio.stream = punchSounds[rand_range(0, 2)]
			enemAudio.play()
		damageframe = false

	var players = get_tree().get_nodes_in_group("player")
	var shortestDistance = null
	for p in players:
		var disto = self.global_transform.origin.distance_to(p.global_transform.origin)
		if shortestDistance == null:
			shortestDistance = p
		elif disto < shortestDistance.global_transform.origin.distance_to(p.global_transform.origin):
			shortestDistance = p
	detect.look_at(shortestDistance.global_transform.origin, Vector3.UP)
	get_parent().player = shortestDistance
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
	get_parent().queue_free()
	queue_free()
