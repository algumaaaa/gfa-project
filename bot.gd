extends KinematicBody

onready var player = get_tree().get_root().get_node("/root/Spatial/player")
onready var playerCamera = get_tree().get_root().get_node("/root/Spatial/player/head/Camera")
onready var navNode = get_parent()

onready var maleSprite = $compositeSprites/maleSprite
onready var nelevenSprite = $compositeSprites/nelevenSprite
onready var doublebSprite = $compositeSprites/doublebSprite
onready var mac10Sprite = $compositeSprites/mac10Sprite
onready var lactionSprite = $compositeSprites/lactionSprite
onready var glauncherSprite = $compositeSprites/glauncherSprite
onready var bandageSprite = $compositeSprites/bandageSprite

export var animframe = 0
onready var animSprite = $animSprite
onready var ammoAudio = $ammoAudio

var gunSounds = []

var aiState = AI.IDLE
var weaponState = WEAPON.NELEVEN
var shortTarget = null
var farPlayer= null
var healTarget = null

var triggerPulled = false
var canShoot = true
var spread = 4
var shootOffset = rand_range(0, 0.5)
var speed = 20
var nelevenammo = 20
var doublebammo = 10
var mac10ammo = 30
var lactionammo = 10
var glauncherammo = 5

var slowed = false
var damagequeue = 0

onready var grenade = preload("res://grenade.tscn")
onready var bloodimpact = preload("res://bloodimpact.tscn")
onready var blood = preload("res://blood.tscn")

enum AI{
	IDLE,
	PATHING,
	ATTACK,
	HEALING,
	DOWNED
}

enum WEAPON{
	NELEVEN,
	DOUBLEB,
	MAC10,
	LACTION,
	GLAUNCHER,
	BANDAGE
}

func _ready():
	randomize()
	gunSounds.append(preload("res://Audio/Guns/neleven/Shot.wav"))
	gunSounds.append(preload("res://Audio/Guns/doubleb/Shot.wav"))
	gunSounds.append(preload("res://Audio/Guns/mac10/Shot.wav"))
	gunSounds.append(preload("res://Audio/Guns/laction/Shot.wav"))
	gunSounds.append(preload("res://Audio/Guns/glauncher/Shot.wav"))

func _process(delta):
	var tr = weakref(shortTarget)
	if (!tr.get_ref()):
		shortTarget = null


func _physics_process(delta):
	if navNode == null:
		return

#	if Input.is_action_just_pressed("debug0"):
#		aiState = AI.DOWNED
	if Input.is_action_just_pressed("debug1"):
		aiState = AI.PATHING
	if Input.is_action_just_pressed("debug2"):
		weaponState = WEAPON.DOUBLEB

	if playerCamera == null:
		return
	var player_foward = playerCamera.global_transform.basis.z
	var foward = global_transform.basis.z
	var left = global_transform.basis.x

	var left_dot = left.dot(player_foward)
	var foward_dot = foward.dot(player_foward)
	var animrow = 0

	maleSprite.flip_h = true
	nelevenSprite.flip_h = true
	doublebSprite.flip_h = true
	mac10Sprite.flip_h = true
	lactionSprite.flip_h = true
	glauncherSprite.flip_h = true
	bandageSprite.flip_h = true

	if foward_dot < -0.85:
		animrow = 0
	elif foward_dot > 0.85:
		animrow = 4
	else: 

		maleSprite.flip_h = left_dot < 0
		nelevenSprite.flip_h = left_dot < 0
		doublebSprite.flip_h = left_dot < 0
		mac10Sprite.flip_h = left_dot < 0
		lactionSprite.flip_h = left_dot < 0
		glauncherSprite.flip_h = left_dot < 0
		bandageSprite.flip_h = left_dot < 0

		if abs(foward_dot) < 0.3:
			animrow = 2
		elif foward_dot < 0:
			animrow = 1
		else:
			animrow = 3

	maleSprite.frame_coords = Vector2(animframe, animrow)
	nelevenSprite.frame_coords = Vector2(animframe, animrow)
	doublebSprite.frame_coords = Vector2(animframe, animrow)
	mac10Sprite.frame_coords = Vector2(animframe, animrow)
	lactionSprite.frame_coords = Vector2(animframe, animrow)
	glauncherSprite.frame_coords = Vector2(animframe, animrow)
	bandageSprite.frame_coords = Vector2(animframe, animrow)

	match weaponState:

		WEAPON.NELEVEN:
			var cc = $compositeSprites.get_children()
			for w in cc:
				w.visible = false
#			$compositeSprites/maleSprite.visible = true
			$compositeSprites/nelevenSprite.visible = true
			if triggerPulled:
				if nelevenammo > 0:
					nelevenammo -= 1
					$aim.cast_to.x = rand_range(spread, -spread)
					$aim.cast_to.y = rand_range(spread, -spread)
					if $aim.get_collider() == shortTarget:
						shortTarget.damagequeue += player.nelevendamage
						shortTarget.tookdamage = true
						var bimp = bloodimpact.instance()
						bimp.enTrig = true
						shortTarget.add_child(bimp)
						bimp.global_transform.origin = $aim.get_collision_point()
						bimp.look_at($aim.get_collision_point() + $aim.get_collision_normal(), Vector3.UP)
						var chanceofgore = rand_range(1, 3)
						if chanceofgore >= 2:
							var bld = blood.instance()
							shortTarget.add_child(bld)
							bld.global_transform.origin = $aim.get_collision_point()
							bld.look_at($aim.get_collision_point() + $aim.get_collision_normal(), Vector3.UP)
						if chanceofgore >= 3:
							var bldd = blood.instance()
							shortTarget.add_child(bldd)
							bldd.global_transform.origin = $aim.get_collision_point()
							bldd.look_at($aim.get_collision_point() + $aim.get_collision_normal(), Vector3.UP)
					$gunSound.stream = gunSounds[0]
					$gunSound.play()
					canShoot = false
					var cdTimer = Timer.new()
					cdTimer.wait_time = 0.25 + shootOffset
					cdTimer.one_shot = true
					cdTimer.connect("timeout", self, "_on_cdTimer_timeout")
					add_child(cdTimer)
					cdTimer.start()
					triggerPulled = false
				else:
					_switchGun()

		WEAPON.DOUBLEB:
			var cc = $compositeSprites.get_children()
			for w in cc:
				w.visible = false
#			$compositeSprites/maleSprite.visible = true
			$compositeSprites/doublebSprite.visible = true
			if triggerPulled:
				if doublebammo > 0:
					doublebammo -= 1
					$aim.cast_to.x = rand_range(spread, -spread)
					$aim.cast_to.y = rand_range(spread, -spread)
					if $aim.get_collider() == shortTarget:
						shortTarget.damagequeue += player.pellet * 9
						shortTarget.tookdamage = true
						var bimp = bloodimpact.instance()
						bimp.enTrig = true
						shortTarget.add_child(bimp)
						bimp.global_transform.origin = $aim.get_collision_point()
						bimp.look_at($aim.get_collision_point() + $aim.get_collision_normal(), Vector3.UP)
						var chanceofgore = rand_range(1, 3)
						if chanceofgore >= 2:
							var bld = blood.instance()
							shortTarget.add_child(bld)
							bld.global_transform.origin = $aim.get_collision_point()
							bld.look_at($aim.get_collision_point() + $aim.get_collision_normal(), Vector3.UP)
						if chanceofgore >= 3:
							var bldd = blood.instance()
							shortTarget.add_child(bldd)
							bldd.global_transform.origin = $aim.get_collision_point()
							bldd.look_at($aim.get_collision_point() + $aim.get_collision_normal(), Vector3.UP)
					$gunSound.stream = gunSounds[1]
					$gunSound.play()
					canShoot = false
					var cdTimer = Timer.new()
					cdTimer.wait_time = 0.62 + shootOffset
					cdTimer.one_shot = true
					cdTimer.connect("timeout", self, "_on_cdTimer_timeout")
					add_child(cdTimer)
					cdTimer.start()
					triggerPulled = false
				else:
					_switchGun()

		WEAPON.MAC10:
			var cc = $compositeSprites.get_children()
			for w in cc:
				w.visible = false
			#$compositeSprites/maleSprite.visible = true
			$compositeSprites/mac10Sprite.visible = true
			if triggerPulled:
				if mac10ammo > 0:
					mac10ammo -= 1
					$aim.cast_to.x = rand_range(spread, -spread)
					$aim.cast_to.y = rand_range(spread, -spread)
					if $aim.get_collider() == shortTarget:
						shortTarget.damagequeue += player.mac10damage
						shortTarget.tookdamage = true
						var bimp = bloodimpact.instance()
						bimp.enTrig = true
						shortTarget.add_child(bimp)
						bimp.global_transform.origin = $aim.get_collision_point()
						bimp.look_at($aim.get_collision_point() + $aim.get_collision_normal(), Vector3.UP)
						var chanceofgore = rand_range(1, 3)
						if chanceofgore >= 2:
							var bld = blood.instance()
							shortTarget.add_child(bld)
							bld.global_transform.origin = $aim.get_collision_point()
							bld.look_at($aim.get_collision_point() + $aim.get_collision_normal(), Vector3.UP)
						if chanceofgore >= 3:
							var bldd = blood.instance()
							shortTarget.add_child(bldd)
							bldd.global_transform.origin = $aim.get_collision_point()
							bldd.look_at($aim.get_collision_point() + $aim.get_collision_normal(), Vector3.UP)
					$gunSound.stream = gunSounds[2]
					$gunSound.play()
					canShoot = false
					var cdTimer = Timer.new()
					cdTimer.wait_time = 0.1 + (shootOffset / 2)
					cdTimer.one_shot = true
					cdTimer.connect("timeout", self, "_on_cdTimer_timeout")
					add_child(cdTimer)
					cdTimer.start()
					triggerPulled = false
				else:
					_switchGun()

		WEAPON.LACTION:
			var cc = $compositeSprites.get_children()
			for w in cc:
				w.visible = false
			#$compositeSprites/maleSprite.visible = true
			$compositeSprites/lactionSprite.visible = true
			if triggerPulled:
				if lactionammo > 0:
					lactionammo -= 1
					$aim.cast_to.x = rand_range(spread, -spread)
					$aim.cast_to.y = rand_range(spread, -spread)
					if $aim.get_collider() == shortTarget:
						shortTarget.damagequeue += player.lactiondamage
						shortTarget.tookdamage = true
						var bimp = bloodimpact.instance()
						bimp.enTrig = true
						shortTarget.add_child(bimp)
						bimp.global_transform.origin = $aim.get_collision_point()
						bimp.look_at($aim.get_collision_point() + $aim.get_collision_normal(), Vector3.UP)
						var chanceofgore = rand_range(1, 3)
						if chanceofgore >= 2:
							var bld = blood.instance()
							shortTarget.add_child(bld)
							bld.global_transform.origin = $aim.get_collision_point()
							bld.look_at($aim.get_collision_point() + $aim.get_collision_normal(), Vector3.UP)
						if chanceofgore >= 3:
							var bldd = blood.instance()
							shortTarget.add_child(bldd)
							bldd.global_transform.origin = $aim.get_collision_point()
							bldd.look_at($aim.get_collision_point() + $aim.get_collision_normal(), Vector3.UP)
					$gunSound.stream = gunSounds[3]
					$gunSound.play()
					canShoot = false
					var cdTimer = Timer.new()
					cdTimer.wait_time = 0.86 + (shootOffset / 2)
					cdTimer.one_shot = true
					cdTimer.connect("timeout", self, "_on_cdTimer_timeout")
					add_child(cdTimer)
					cdTimer.start()
					triggerPulled = false
				else:
					_switchGun()

		WEAPON.GLAUNCHER:
			var cc = $compositeSprites.get_children()
			for w in cc:
				w.visible = false
			#$compositeSprites/maleSprite.visible = true
			$compositeSprites/glauncherSprite.visible = true
			if triggerPulled:
				if glauncherammo > 0:
					glauncherammo -= 1
					var g = grenade.instance()
					$lookAt.add_child(g)
					g.look_at(shortTarget.global_transform.origin, Vector3.UP)
					g.shoot = true
					$gunSound.stream = gunSounds[4]
					$gunSound.play()
					canShoot = false
					var cdTimer = Timer.new()
					cdTimer.wait_time = 1 + shootOffset
					cdTimer.one_shot = true
					cdTimer.connect("timeout", self, "_on_cdTimer_timeout")
					add_child(cdTimer)
					cdTimer.start()
					triggerPulled = false
				else:
					_switchGun()

		WEAPON.BANDAGE:
			var cc = $compositeSprites.get_children()
			for w in cc:
				w.visible = false
			#$compositeSprites/maleSprite.visible = true
			$compositeSprites/bandageSprite.visible = true

	match aiState:

		AI.IDLE:
			navNode.navstate = navNode.STOPPED
			animSprite.stop()
			if weaponState == WEAPON.BANDAGE or weaponState == WEAPON.NELEVEN or weaponState == WEAPON.MAC10:
				animframe = 0
			else:
				animframe = 7
			_findFarPlayer()
			if self.global_transform.origin.distance_to(farPlayer.global_transform.origin) > 20:
				aiState = AI.PATHING
			else:
				_findEnemies()

		AI.PATHING:
			navNode.navstate = navNode.PATHING
			if weaponState == WEAPON.BANDAGE or weaponState == WEAPON.NELEVEN or weaponState == WEAPON.MAC10:
				if !animSprite.is_playing():
					animSprite.play("runPistol")
			else:
				if !animSprite.is_playing():
					animSprite.play("runRifle")
			if !Vector3.UP.cross(navNode.navdir - global_transform.origin) == Vector3():
				$lookAt.look_at(navNode.navdir, Vector3.UP)
			rotate_y(deg2rad($lookAt.rotation.y * 10))
			if self.global_transform.origin.distance_to(farPlayer.global_transform.origin) > 20:
				pass
			elif navNode.currentpathindex >= navNode.path.size():
				aiState = AI.IDLE

		AI.ATTACK:
			navNode.navstate = navNode.STOPPED
			animSprite.stop()
			if weaponState == WEAPON.BANDAGE or weaponState == WEAPON.NELEVEN or weaponState == WEAPON.MAC10:
				animframe = 0
			else:
				animframe = 7

			var tr = weakref(shortTarget)
			if (!tr.get_ref()):
				shortTarget = null
				aiState = AI.IDLE
			else:
				$aim.look_at(shortTarget.global_transform.origin, Vector3.UP)
				$lookAt.look_at(shortTarget.global_transform.origin, Vector3.UP)
				rotate_y(deg2rad($lookAt.rotation.y * 10))
				if canShoot:
					triggerPulled = true
				if shortTarget.health <= 0:
					shortTarget = null
					aiState = AI.IDLE
			if self.global_transform.origin.distance_to(farPlayer.global_transform.origin) > 20:
				aiState = AI.PATHING
			else:
				pass

		AI.HEALING:
			navNode.navstate = navNode.HEALING

		AI.DOWNED:
			navNode.navstate = navNode.STOPPED
			animSprite.stop()
			animframe = 14

func _findFarPlayer():
	var targets = get_tree().get_nodes_in_group("player")
	for t in targets:
		var disto = self.global_transform.origin.distance_to(t.global_transform.origin)
		if farPlayer == null:
			farPlayer = t
		elif disto > farPlayer.global_transform.origin.distance_to(t.global_transform.origin):
			farPlayer = t

func _findEnemies():
	var targets = get_tree().get_nodes_in_group("alertEnemies")
	#create softref to shortTargets in the loop and only apply it after its done
	for t in targets:
		var disto = self.global_transform.origin.distance_to(t.global_transform.origin)
		if shortTarget == null:
			shortTarget = t
		elif disto < shortTarget.global_transform.origin.distance_to(t.global_transform.origin):
			shortTarget = t
	if shortTarget == null:
		return
	if self.global_transform.origin.distance_to(shortTarget.global_transform.origin) < 30:
		aiState = AI.ATTACK

func _switchGun():
	weaponState = randi()%5

func _on_cdTimer_timeout():
	canShoot = true
