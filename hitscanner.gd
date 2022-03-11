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

onready var navnode = get_parent()
onready var player = get_tree().get_root().get_node("/root/Spatial/player/")
onready var ray = $RayCast
onready var lookat = $lookat

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
			navnode.navstate = navnode.STOPPED
			animframe = 0
			animplay.stop()

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
			if ready == true:
				if tookdamage == false:
					animplay.play("attack")
			else:
				animplay.play("unsheathe")
			var tt = ray.get_collider()
			if tt == null:
				return
			lookat.look_at(tt.global_transform.origin, Vector3.UP)
			rotate_y(deg2rad(lookat.rotation.y * 10))

		AI.DIE:
			navnode.navstate = navnode.STOPPED
			if despawn.is_stopped():
				animplay.play("death")
				despawn.start()
			ray.enabled = false
			hitbox.disabled = true
			ispathing = false
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
			ispathing = false
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
					despawn.start()
					self.visible = false
				navnode.hitbox.disabled = true
				navnode.tick.stop()
#				var playerGroup = get_tree().get_nodes_in_group("player")
#				for p in playerGroup:
#					if p.shortTarget == self:
#						p._findEnemies()
#				queue_free()

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

	ray.look_at(player.global_transform.origin, Vector3.UP)
	if ray.is_colliding() and !ispathing and !tookdamage:
		var collider = ray.get_collider()
		if collider.is_in_group("player"):
			ispathing = false
			aistate = AI.ATTACK
		elif collider.is_in_group("enemies"):
			aistate = AI.PATHING
			ispathing = true

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
	var players = get_tree().get_nodes_in_group("player")
	var st = false
	for p in players:
		if p.shortTarget == self:
			st = true
	if st:
		despawn.start()
		st = false
	else:
		get_parent().queue_free()
		queue_free()
