extends KinematicBody

var health = 1000
var damagequeue = 0
var tookdamage = false
var aistate = AI.IDLE
var patience = 50
var charging = false

var wspeed = 10
var rspeed = 50
var path = []
var currentpathindex = 0
var randompath = Vector3()

onready var nav = get_parent()
onready var player = get_tree().get_root().get_node("/root/Spatial/player/")
onready var ray = $RayCast
onready var lookat = $lookat
onready var detect = $detect

export var damageray = false
onready var damagezone = $hitbox
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
	PREP,
	CHARGE,
	ATTACK,
	PAIN,
	DIE,
	GORE,
	GIB
}

func _ready():
	damageray = false

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
			if !animplay.is_playing():
				animplay.play("walk")
			if currentpathindex < path.size():
				var direction = (path[currentpathindex] - global_transform.origin)
				if direction.length() < 1:
					currentpathindex += 1
				else:
					move_and_slide(direction.normalized() * wspeed, Vector3.UP)
					lookat.look_at(path[currentpathindex], Vector3.UP)
					rotate_y(deg2rad(lookat.rotation.y * 5))
		AI.PREP:
			animplay.play("prep")
		AI.CHARGE:
			if !animplay.is_playing():
				animplay.play("run")
			lookat.look_at(player.global_transform.origin, Vector3.UP)
			rotate_y(deg2rad(lookat.rotation.y * 10))
			if currentpathindex < path.size():
				var direction = (path[currentpathindex] - global_transform.origin)
				if direction.length() < 1:
					currentpathindex += 1
				else:
					move_and_slide(direction.normalized() * rspeed, Vector3.UP)
			for body in damagezone.get_overlapping_bodies():
				if body.is_in_group("player"):
					body.damagequeue += 20
					var direction = self.transform.origin - player.transform.origin
					player.global_transform.origin = lerp(player.transform.origin, player.transform.origin - direction * 3, 0.5)
					aistate = AI.PREP
		AI.PAIN:
			if damagequeue > 50:
				tookdamage = false
				animplay.play("pain")
			if damagequeue <= 50:
				tookdamage = false
				if health > 0:
					aistate = AI.ALERT
					damagequeue = 0
		AI.ATTACK:
			if tookdamage == false and (aistate != AI.CHARGE and aistate != AI.PREP):
				animplay.play("attack")
		AI.DIE:
			if despawn.is_stopped():
				animplay.play("death")
				despawn.start()
			ray.enabled = false
			damageray = false
			hitbox.disabled = true
			tick.stop()
		AI.GORE:
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
		AI.GIB:
			if despawn.is_stopped():
				for i in 5:
					var g = gore.instance()
					g.hh = i + 5
					g.scale = Vector3(1.5, 1.5, 1.5)
					self.get_parent().add_child(g)
					g.global_transform.origin = self.global_transform.origin
					g.gibbed = true
				queue_free()

	if tookdamage == true:

		health -= damagequeue
		if health > 0 and (aistate != AI.CHARGE and aistate != AI.PREP):
			aistate = AI.PAIN
		if health > 0 and (aistate == AI.CHARGE or aistate == AI.PREP):
			tookdamage = false
			damagequeue = 0
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

func get_target_path(target_pos):
	if aistate == AI.ALERT or aistate == AI.CHARGE:
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
	if aistate == AI.ALERT:
		get_target_path(player.global_transform.origin)
		if patience > 0:
			patience -= 1
		else:
			aistate = AI.PREP
	if aistate == AI.CHARGE:
		get_target_path(player.global_transform.origin)
		if patience < 50:
			patience += 10
		else:
			aistate = AI.ALERT

func _on_Area_body_entered(body):
	if body.is_in_group("player") and (aistate == AI.IDLE or aistate == AI.ALERT):
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
	queue_free()
