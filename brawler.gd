extends KinematicBody

var health = 1000
var damagequeue = 0
var tookdamage = false
var aistate = AI.IDLE
var patience = 50
var freed = false
var charging = false

var speed = 10
var ispathing = false
var path = []
var currentpathindex = 0
var randompath = Vector3()

onready var navnode = get_parent()
onready var player = get_tree().get_root().get_node("/root/Spatial/player/")
onready var ray = $RayCast
onready var lookat = $lookat
onready var detect = $detect

export var damageray = false
onready var tick = $tick
onready var damagezone = $hitbox
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
	PREP,
	CHARGE,
	ATTACK,
	PAIN,
	DIE,
	GORE,
	GIB,
	PATHING
}

func _ready():
	damageray = false

func _process(delta):
	if camera == null or freed:
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
	if freed:
		return

	if Input.is_action_just_pressed("debug0"):
		aistate = AI.GIB

	match aistate:

		AI.IDLE:
			navnode.navstate = navnode.STOPPED
			animframe = 0
			animplay.stop()

		AI.ALERT:
			add_to_group("alertEnemies")
			speed = 10
			navnode.navstate = navnode.ALERT
			if !animplay.is_playing():
				animplay.play("walk")
			if !Vector3.UP.cross(navnode.navdir - global_transform.origin) == Vector3():
				lookat.look_at(navnode.navdir, Vector3.UP)
			rotate_y(deg2rad(lookat.rotation.y * 5))

		AI.PREP:
			navnode.navstate = navnode.STOPPED
			animplay.play("prep")

		AI.CHARGE:
			speed = 50
			navnode.navstate = navnode.ALERT
			if !animplay.is_playing():
				animplay.play("run")
			if !Vector3.UP.cross(navnode.navdir - global_transform.origin) == Vector3():
				lookat.look_at(navnode.navdir, Vector3.UP)
			rotate_y(deg2rad(lookat.rotation.y * 10))
			for body in damagezone.get_overlapping_bodies():
				if body.is_in_group("player"):
					body.damagequeue += 20
					var direction = navnode.transform.origin - body.transform.origin
					body.global_transform.origin = lerp(body.transform.origin, body.transform.origin - direction * 3, 0.5)
					aistate = AI.PREP

		AI.PAIN:
			if damagequeue > 50:
				navnode.navstate = navnode.STOPPED
				tookdamage = false
				animplay.play("pain")
			if damagequeue <= 50:
				tookdamage = false
				if health > 0:
					aistate = AI.ALERT
					damagequeue = 0

		AI.ATTACK:
			navnode.navstate = navnode.STOPPED
			if tookdamage == false and (aistate != AI.CHARGE and aistate != AI.PREP):
				animplay.play("attack")

		AI.DIE:
			navnode.navstate = navnode.STOPPED
			if despawn.is_stopped():
				animplay.play("death")
				despawn.start()
			ray.enabled = false
			damageray = false
			hitbox.disabled = true
			tick.stop()
			navnode.hitbox.disabled = true
			navnode.tick.stop()
			detect.enabled = false

		AI.GORE:
			navnode.navstate = navnode.STOPPED
			if despawn.is_stopped():
				animplay.play("deathgore")
				var g = gore.instance()
				g.hh = 7
				self.add_child(g)
				g.global_transform.origin = self.global_transform.origin
				g.gibbed = false
				despawn.start()
			ray.enabled = false
			hitbox.disabled = true
			tick.stop()
			navnode.hitbox.disabled = true
			navnode.tick.stop()
			detect.enabled = false

		AI.GIB:
			navnode.navstate = navnode.STOPPED
			if despawn.is_stopped():
				for i in 5:
					var g = gore.instance()
					g.hh = i + 5
					g.scale = Vector3(1.5, 1.5, 1.5)
					self.get_parent().add_child(g)
					g.global_transform.origin = self.global_transform.origin
					g.gibbed = true
					despawn.start()
					self.visible = false
			tick.stop()
			ray.enabled = false
			hitbox.disabled = true
			navnode.hitbox.disabled = true
			navnode.tick.stop()
			detect.enabled = false
#				var playerGroup = get_tree().get_nodes_in_group("player")
#				for p in playerGroup:
#					if p.shortTarget == self:
#						p._findEnemies()
#				queue_free()

	if tookdamage == true:

		health -= damagequeue
		if health > 0 and (aistate != AI.CHARGE and aistate != AI.PREP):
			aistate = AI.PAIN
		if health > 0 and (aistate == AI.CHARGE or aistate == AI.PREP):
			tookdamage = false
			damagequeue = 0
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

	if ray.is_colliding() and aistate == AI.ALERT:
		var target = ray.get_collider()
		if target.is_in_group("player"):
			aistate = AI.ATTACK
		if target.is_in_group("enemies"):
			aistate = AI.ATTACK

	if damageray:
		for body in damagezone.get_overlapping_bodies():
			if body.is_in_group("enemies"):
				body.damagequeue += 100
				body.tookdamage = true
				damageray = false
			if body.is_in_group("player"):
				body.damagequeue += 10
				damageray = false

	detect.look_at(player.global_transform.origin, Vector3.UP)
	if detect and aistate == AI.IDLE:
		var p = detect.get_collider()
		if p != null:
			if p.is_in_group("player"):
				animplay.stop()
				aistate = AI.ALERT

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "attack":
		if damageray:
			damageray = false
		aistate = AI.ALERT
	if anim_name == "pain":
		damagequeue = 0
		if health > 0:
			aistate = AI.ALERT
	if anim_name == "prep":
		aistate = AI.CHARGE

func _on_despawn_timeout():
#	var players = get_tree().get_nodes_in_group("player")
#	var st = false
#	for p in players:
#		if p.shortTarget == self:
#			st = true
#	if st:
#		despawn.start()
#		st = false
#	else:
#		get_parent().queue_free()
#		queue_free()
	freed = true

func _on_tick_timeout():
	if aistate == AI.ALERT:
		if patience > 0:
			patience -= 1
		else:
			aistate = AI.PREP
	if aistate == AI.CHARGE:
		if patience < 50:
			patience += 10
		else:
			aistate = AI.ALERT
