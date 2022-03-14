extends KinematicBody

var pellet = 12
var pelletspread = 7
var nelevendamage = 35
var lactiondamage = 110
var mac10damage = 35

var doublebchambered = 2
var nelevenammo = 30
var doublebammo = 16
var lactionammo = 20
var glauncherammo = 10
var mac10ammo = 100
var heals = 3

var hasFlashlight = false
var hasDoubleb = false
var hasMac10 = false
var hasLaction = false
var hasGlauncher = false

var health = 100
var damagequeue = 0
var healqueue = 0
var speed = 20
var bloody = 0
var slowed = false
var shortTarget = null
var ammoPickedUp = false

var direction = Vector3()
var h_acceleration = 25
var h_velocity = Vector3()
var movement = Vector3()
var hasControl = true

var deathCount = 30
var gravity = 30
var jump = 10
var gravity_vec = Vector3()
var full_contact = false
var air_acceleration = 2
var normal_acceleration = 6

var gunstate = GUN_USE.GUN1
var gunequip = neleven
var nextgun = GUN_USE.GUN1

export var footStep = false
var footStepAudios = []

enum GUN_USE {
	HEAL,
	GUN1,
	GUN2,
	GUN3,
	GUN4,
	GUN5,
	UNEQUIP
}

onready var GLOBAL = get_node("/root/GLOBAL/")
onready var eventManager = null
var startCutscene = false

onready var head = $head
onready var ground_check = $groundcheck
onready var aim = $head/Camera/aim
onready var camera = $head/Camera
onready var guncam = $head/Camera/ViewportContainer/Viewport/guncam
onready var shootshake = $head/Camera/camerashake
onready var gunbob = $head/Camera/ViewportContainer/Viewport/guncam/AnimationPlayer
onready var viewport = $head/Camera/ViewportContainer/Viewport

onready var rftop = $bump/ftop
onready var rfbottom = $bump/fbottom
onready var rbtop = $bump/btop
onready var rbbottom = $bump/bbottom
onready var rltop = $bump/ltop
onready var rlbottom = $bump/lbottom
onready var rrtop = $bump/rtop
onready var rrbottom = $bump/rbottom

onready var band = $head/Camera/band
onready var bandaid = $head/Camera/bandaid
onready var mac10 = $head/Camera/mac10
onready var laction = $head/Camera/laction
onready var glauncher = $head/Camera/glauncher
onready var neleven = $head/Camera/neleven
onready var doubleb = $head/Camera/doubleb
onready var gunanim = $head/Camera/gunanim

onready var muzzle = $head/muzzle
onready var shellsloc = $head/shellsrelease
onready var shellslocleft = $head/shellsrelease2
onready var doublebcontainer = $head/Camera/doublebcontainer

onready var footAudio = $footAudio
onready var ammoAudio = $ammoAudio

onready var bullethole = preload("res://bullethole.tscn")
onready var bcasing = preload("res://bulletcasing.tscn")
onready var blood = preload("res://blood.tscn")
onready var bloodimpact = preload("res://bloodimpact.tscn")
onready var grenade = preload("res://grenade.tscn")
onready var ammoThrown = preload("res://ammoThrown.tscn")

func _input(event):
	if !hasControl:
		return
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * GLOBAL.mouse_sensitivity))
		head.rotate_x(deg2rad(-event.relative.y * GLOBAL.mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-89), deg2rad(89))

func _process(delta):
	guncam.global_transform = camera.global_transform
	pass

func _physics_process(delta):
	if !hasControl:
		return

	direction = Vector3()
	full_contact = ground_check.is_colliding()
	
	if not is_on_floor():
		gravity_vec += Vector3.DOWN * gravity * delta 
		h_acceleration = air_acceleration
	elif is_on_floor() and full_contact:
		gravity_vec = -get_floor_normal() * gravity
		h_acceleration = normal_acceleration
	else:
		gravity_vec = -get_floor_normal()
		h_acceleration = normal_acceleration

	if health > 0:
		if Input.is_action_pressed("healing"):
			if gunstate != GUN_USE.UNEQUIP:
				nextgun = GUN_USE.HEAL
		if Input.is_action_pressed("weap1"):
			if gunstate != GUN_USE.UNEQUIP:
				nextgun = GUN_USE.GUN1
		if Input.is_action_pressed("weap2"):
			if gunstate != GUN_USE.UNEQUIP and hasDoubleb:
				nextgun = GUN_USE.GUN2
		if Input.is_action_pressed("weap4") and hasLaction:
			if gunstate != GUN_USE.UNEQUIP:
				nextgun = GUN_USE.GUN3
		if Input.is_action_pressed("weap5") and hasGlauncher:
			if gunstate != GUN_USE.UNEQUIP:
				nextgun = GUN_USE.GUN4
		if Input.is_action_pressed("weap3") and hasMac10:
			if gunstate != GUN_USE.UNEQUIP:
				nextgun = GUN_USE.GUN5

		if Input.is_action_pressed("jump") and (ground_check.is_colliding()):
			gravity_vec = Vector3.UP * jump
		if Input.is_action_pressed("move_foward"):
			direction -= transform.basis.z
		elif Input.is_action_pressed("move_backward"):
			direction += transform.basis.z
		if Input.is_action_pressed("move_left"):
			direction -= transform.basis.x
		elif Input.is_action_pressed("move_right"):
			direction += transform.basis.x


	match gunstate:
		GUN_USE.HEAL:
			gunequip = bandaid
			bandaid.visible = true
			if nextgun != GUN_USE.HEAL and !gunanim.is_playing():
				gunstate = GUN_USE.UNEQUIP
		GUN_USE.GUN1:
			gunequip = neleven
			neleven.visible = true
			if nextgun != GUN_USE.GUN1 and !gunanim.is_playing():
				gunstate = GUN_USE.UNEQUIP
		GUN_USE.GUN2:
			gunequip = doubleb
			doubleb.visible = true
			if nextgun != GUN_USE.GUN2 and !gunanim.is_playing():
				gunstate = GUN_USE.UNEQUIP
		GUN_USE.GUN3:
			gunequip = laction
			laction.visible = true
			if nextgun != GUN_USE.GUN3 and !gunanim.is_playing():
				gunstate = GUN_USE.UNEQUIP
		GUN_USE.GUN4:
			gunequip = glauncher
			glauncher.visible = true
			if nextgun != GUN_USE.GUN4 and !gunanim.is_playing():
				gunstate = GUN_USE.UNEQUIP
		GUN_USE.GUN5:
			gunequip = mac10
			mac10.visible = true
			if nextgun != GUN_USE.GUN5 and !gunanim.is_playing():
				gunstate = GUN_USE.UNEQUIP
		GUN_USE.UNEQUIP:
			if gunequip == bandaid:
				gunanim.play("bandaidunequip")
			if gunequip == neleven:
				gunanim.play("nelevenunequip")
			if gunequip == doubleb:
				gunanim.play("doublebunequip")
			if gunequip == laction:
				gunanim.play("lactionunequip")
			if gunequip == glauncher:
				gunanim.play("glauncherunequip")
			if gunequip == mac10:
				gunanim.play("mac10unequip")

	if Input.is_action_just_pressed("fire"):
		if gunstate == GUN_USE.GUN1:
			if !gunanim.is_playing() and nelevenammo > 0:
				gunanim.play("nelevenshoot")
				shootshake.play("shoot")
				nelevenammo -= 1
				if aim.is_colliding():
					var target = aim.get_collider()
					if target.is_in_group("enemies"):
						target.damagequeue += nelevendamage
						target.tookdamage = true
						var bimp = bloodimpact.instance()
						aim.get_collider().add_child(bimp)
						bimp.global_transform.origin = aim.get_collision_point()
						bimp.look_at(aim.get_collision_point() + aim.get_collision_normal(), Vector3.UP)
						var chanceofgore = rand_range(1, 3)
						if chanceofgore >= 2:
							var bld = blood.instance()
							aim.get_collider().add_child(bld)
							bld.global_transform.origin = aim.get_collision_point()
							bld.look_at(aim.get_collision_point() + aim.get_collision_normal(), Vector3.UP)
						if chanceofgore >= 3:
							var bldd = blood.instance()
							aim.get_collider().add_child(bldd)
							bldd.global_transform.origin = aim.get_collision_point()
							bldd.look_at(aim.get_collision_point() + aim.get_collision_normal(), Vector3.UP)
					if !target.is_in_group("enemies") and !target.is_in_group("player"):
						var bh = bullethole.instance()
						makebh(aim.get_collider(), aim, bh)

		if gunstate == GUN_USE.GUN2:
			for r in doublebcontainer.get_children():
				if !gunanim.is_playing() and r.is_colliding() and doublebammo > 0:
					r.cast_to.x = rand_range(pelletspread, -pelletspread)
					r.cast_to.y = rand_range(pelletspread, -pelletspread)
					if r.get_collider().is_in_group("enemies"):
						r.get_collider().damagequeue += pellet
						r.get_collider().tookdamage = true
						var bimp = bloodimpact.instance()
						r.get_collider().add_child(bimp)
						bimp.global_transform.origin = r.get_collision_point()
						bimp.look_at(r.get_collision_point() + r.get_collision_normal(), Vector3.UP)
						var chanceofgore = rand_range(1, 3)
						if chanceofgore > 2:
							var bld = blood.instance()
							var targetblood = aim.get_collider()
							if targetblood != null: targetblood.add_child(bld)
							bld.global_transform.origin = aim.get_collision_point()
							bld.look_at(aim.get_collision_point() + aim.get_collision_normal(), Vector3.UP)
					var target = r.get_collider()
					if !target.is_in_group("enemies") and !target.is_in_group("player"):
						var bh = bullethole.instance()
						makebh(r.get_collider(), r, bh)
#						r.get_collider().add_child(bh)
#						bh.global_transform.origin = r.get_collision_point()
#						bh.look_at(r.get_collision_point() + r.get_collision_normal(), Vector3.UP)
			if doublebchambered == 2:
				if !gunanim.is_playing() and doublebammo > 0:
					gunanim.play("doublebshoot")
					shootshake.play("shootheavy")
					doublebchambered -= 1
					doublebammo -= 1
			else:
				if !gunanim.is_playing() and doublebammo > 0:
					gunanim.play("doublebreload")
					shootshake.play("shootheavy")
					doublebchambered = 2
					doublebammo -= 1

		if gunstate == GUN_USE.GUN3:
			if !gunanim.is_playing() and lactionammo > 0:
				gunanim.play("lactionshoot")
				shootshake.play("shootheavy")
				lactionammo -= 1
				if aim.is_colliding():
					var target = aim.get_collider()
					if target.is_in_group("enemies"):
						target.damagequeue += lactiondamage
						target.tookdamage = true
						var bimp = bloodimpact.instance()
						aim.get_collider().add_child(bimp)
						bimp.global_transform.origin = aim.get_collision_point()
						bimp.look_at(aim.get_collision_point() + aim.get_collision_normal(), Vector3.UP)
						var bld = blood.instance()
						aim.get_collider().add_child(bld)
						bld.global_transform.origin = aim.get_collision_point()
						bld.look_at(aim.get_collision_point() + aim.get_collision_normal(), Vector3.UP)

#						var worldstate = get_world().direct_space_state
#						var pierce = worldstate.intersect_ray(aim.get_collision_point() + Vector3(0, 0, -3), aim.get_collider().transform.origin + Vector3(0, 0, 10), [aim.get_collider()])
#						if pierce:
#							print(pierce.collider)
#							if pierce.collider.is_in_group("enemies"):
#								pierce.collider.damagequeue += lactiondamage
#							if !pierce.collider.is_in_group("enemies"):
#								var bh = bullethole.instance()
#								aim.get_collider().add_child(bh)
#								bh.global_transform.origin = aim.get_collision_point()
#								bh.look_at(aim.get_collision_point() + aim.get_collision_normal(), Vector3.UP)
		
					if !target.is_in_group("enemies") and !target.is_in_group("player"):
						var bh = bullethole.instance()
						makebh(aim.get_collider(), aim, bh)

		if gunstate == GUN_USE.GUN4:
			if !gunanim.is_playing() and glauncherammo > 0:
				gunanim.play("glaunchershoot")
				glauncherammo -= 1
				var g = grenade.instance()
				muzzle.add_child(g)
				g.look_at(aim.get_collision_point(), Vector3.UP)
				g.shoot = true

	if Input.is_action_pressed("fire"):
		if gunstate == GUN_USE.HEAL:
			if !gunanim.is_playing() and heals > 0:
				gunanim.play("bandaiduse")
		if gunstate == GUN_USE.GUN5:
			if !gunanim.is_playing() and mac10ammo > 0:
				gunanim.play("mac10shoot")
				shootshake.play("shoot")
				mac10ammo -= 1
				var macos = rand_range(-10, 10)
				mac10.offset = Vector2(macos, macos * 0.5)
#				aim.translation = lerp(aim.translation, Vector3(macos * 0.04, macos * 0.04, 0), 0.5)
				aim.cast_to.x = rand_range(macos * 5, -macos * 5)
				aim.cast_to.y = rand_range(macos * 5, -macos * 5)
#				camera.translation = lerp(camera.translation, Vector3(macos * 0.02, macos * 0.02, 0), 0.5)
				if aim.is_colliding():
					var target = aim.get_collider()
					if target.is_in_group("enemies"):
						target.damagequeue += mac10damage
						target.tookdamage = true
						var bimp = bloodimpact.instance()
						aim.get_collider().add_child(bimp)
						bimp.global_transform.origin = aim.get_collision_point()
						bimp.look_at(aim.get_collision_point() + aim.get_collision_normal(), Vector3.UP)
						var bld = blood.instance()
						aim.get_collider().add_child(bld)
						bld.global_transform.origin = aim.get_collision_point()
						bld.look_at(aim.get_collision_point() + aim.get_collision_normal(), Vector3.UP)
					if !target.is_in_group("enemies") and !target.is_in_group("player"):
						var bh = bullethole.instance()
						makebh(aim.get_collider(), aim, bh)
	if Input.is_action_just_released("fire"):
		if gunstate == GUN_USE.HEAL:
			if gunanim.is_playing() and nextgun == GUN_USE.HEAL:
				gunanim.stop(true)
				band.visible = false
		if gunstate == GUN_USE.GUN5:
			aim.translation = Vector3()
#			camera.translation = Vector3()
			if !gunanim.is_playing():
				mac10.offset = Vector2(0, 0)

	if Input.is_action_just_pressed("interact"):
		if aim.is_colliding():
			var target = aim.get_collider()
			var disto = global_transform.origin.distance_to(target.global_transform.origin)
			print(disto)
			if target.is_in_group("buttons") and (disto <= 5):
				target.interact = true

	if Input.is_action_just_pressed("throw_ammo"):
		if gunstate == GUN_USE.GUN1 and nelevenammo > 10:
			nelevenammo -= 10
			var a = ammoThrown.instance()
			muzzle.add_child(a)
			a.look_at(aim.get_collision_point(), Vector3.UP)
			a.shot = true
			a.ammoAmount = 10
			a.ammoType = 0
		if gunstate == GUN_USE.GUN2 and doublebammo > 5:
			doublebammo -= 5
			var a = ammoThrown.instance()
			muzzle.add_child(a)
			a.look_at(aim.get_collision_point(), Vector3.UP)
			a.shot = true
			a.ammoAmount = 5
			a.ammoType = 1
		if gunstate == GUN_USE.GUN5 and mac10ammo > 10:
			mac10ammo -= 10
			var a = ammoThrown.instance()
			muzzle.add_child(a)
			a.look_at(aim.get_collision_point(), Vector3.UP)
			a.shot = true
			a.ammoAmount = 10
			a.ammoType = 2
		if gunstate == GUN_USE.GUN3 and lactionammo > 10:
			lactionammo -= 10
			var a = ammoThrown.instance()
			muzzle.add_child(a)
			a.look_at(aim.get_collision_point(), Vector3.UP)
			a.shot = true
			a.ammoAmount = 10
			a.ammoType = 3
		if gunstate == GUN_USE.GUN4 and glauncherammo > 5:
			glauncherammo -= 5
			var a = ammoThrown.instance()
			muzzle.add_child(a)
			a.look_at(aim.get_collision_point(), Vector3.UP)
			a.shot = true
			a.ammoAmount = 5
			a.ammoType = 4
		if gunstate == GUN_USE.HEAL and heals > 0:
			if !gunanim.is_playing():
				gunanim.play("bandaiduseOnAlly")

	if Input.is_action_just_released("throw_ammo"):
		if gunstate == GUN_USE.HEAL:
			if gunanim.is_playing() and nextgun == GUN_USE.HEAL:
				gunanim.stop(true)
				band.visible = false

	if Input.is_action_just_pressed("flashlight"):
		if hasFlashlight:
			if $head/Camera/flashLight.visible != true:
				$head/Camera/flashLight.visible = true
			else:
				$head/Camera/flashLight.visible = false

	if neleven.shellsrelease:
		var nelshells = bcasing.instance()
		nelshells.bullettype = 1
		shellsloc.add_child(nelshells)
		nelshells.look_at(aim.get_collision_point(), Vector3.UP)
		neleven.shellsrelease = false

	if doubleb.shellsrelease:
		var sgshells = bcasing.instance()
		sgshells.bullettype = 2
		shellsloc.add_child(sgshells)
		sgshells.look_at(aim.get_collision_point(), Vector3.UP)
		var sgshell = bcasing.instance()
		sgshell.bullettype = 2
		shellsloc.add_child(sgshell)
		sgshell.look_at(aim.get_collision_point(), Vector3.UP)
		doubleb.shellsrelease = false

	if laction.shellsrelease:
		var lashells = bcasing.instance()
		lashells.bullettype = 3
		shellslocleft.add_child(lashells)
		lashells.look_at(aim.get_collision_point(), Vector3.UP)
		laction.shellsrelease = false

	if glauncher.shellsrelease:
		var gshells = bcasing.instance()
		gshells.bullettype = 4
		shellsloc.add_child(gshells)
		gshells.look_at(aim.get_collision_point(), Vector3.UP)
		glauncher.shellsrelease = false

	if mac10.shellsrelease:
		var macshells = bcasing.instance()
		macshells.bullettype = 1
		shellsloc.add_child(macshells)
		macshells.look_at(aim.get_collision_point(), Vector3.UP)
		mac10.shellsrelease = false

	if rfbottom.is_colliding() and !rftop.is_colliding() and Input.is_action_pressed("move_foward"):
		var col = Vector3()
		col = rfbottom.get_collision_normal()
		col = col.normalized()
		if is_zero_approx(col.y) == true:
			gravity_vec = Vector3.UP * 3
	if rbbottom.is_colliding() and !rbtop.is_colliding() and Input.is_action_pressed("move_backward"):
		var col = Vector3()
		col = rbbottom.get_collision_normal()
		col = col.normalized()
		if is_zero_approx(col.y) == true:
			gravity_vec = Vector3.UP * 3
	if rlbottom.is_colliding() and !rltop.is_colliding() and Input.is_action_pressed("move_left"):
		var col = Vector3()
		col = rlbottom.get_collision_normal()
		col = col.normalized()
		if is_zero_approx(col.y) == true:
			gravity_vec = Vector3.UP * 3
	if rrbottom.is_colliding() and !rrtop.is_colliding() and Input.is_action_pressed("move_right"):
		var col = Vector3()
		col = rrbottom.get_collision_normal()
		col = col.normalized()
		if is_zero_approx(col.y) == true:
			gravity_vec = Vector3.UP * 3

	direction = direction.normalized()
	h_velocity = h_velocity.linear_interpolate(direction * speed, h_acceleration * delta)
	movement.z = h_velocity.z + gravity_vec.z
	movement.x = h_velocity.x + gravity_vec.x
	movement.y = gravity_vec.y
	move_and_slide(movement, Vector3.UP)
	
	if is_on_floor() and direction != Vector3():
		gunbob.play("gunbob")
	else:
		gunbob.stop(false)

	if damagequeue > 0:
		health -= damagequeue
		damagequeue = 0
	if healqueue > 0:
		health += healqueue
		healqueue = 0
		if health <= 0:
			$death.stop()
			$head/Camera/deathAnim.stop(true)
			gunbob.stop(true)
			deathCount = 30
	if health <= 0:
		health = 0
		_death()

	if health > 100:
		health = 100

	if footStep:
		footAudio.stream = footStepAudios[rand_range(0, 4)]
		footAudio.play()
		footStep = false

	if slowed:
		speed = 10
		var slowTimer = Timer.new()
		slowTimer.wait_time = 1
		slowTimer.one_shot = true
		slowTimer.connect("timeout", self, "_on_slowTimer_timeout")
		add_child(slowTimer)
		slowTimer.start()

	if ammoPickedUp:
		ammoPickedUp = false

func _ready():
	GLOBAL.player = self
	camera.fov = GLOBAL.fov
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	randomize()
	for r in doublebcontainer.get_children():
		r.cast_to.x = rand_range(pelletspread, -pelletspread)
		r.cast_to.y = rand_range(pelletspread, -pelletspread)

	bandaid.visible = false
	band.visible = false
	doubleb.visible = false
	laction.visible = false
	glauncher.visible = false
	mac10.visible = false
	startCutscene = true

	footStepAudios.append(preload("res://Audio/Misc/Footsteps/Footstep1.wav"))
	footStepAudios.append(preload("res://Audio/Misc/Footsteps/Footstep2.wav"))
	footStepAudios.append(preload("res://Audio/Misc/Footsteps/Footstep3.wav"))
	footStepAudios.append(preload("res://Audio/Misc/Footsteps/Footstep4.wav"))
	footStepAudios.append(preload("res://Audio/Misc/Footsteps/Footstep5.wav"))

	viewport.size = get_viewport().get_visible_rect().size

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

func _on_slowTimer_timeout():
	speed = 20
	slowed = false

func _toggleControl(value: bool):
	if value:
		hasControl = true
	if !value:
		hasControl = false

func _death():
	if gunstate != GUN_USE.GUN1:
		if gunstate != GUN_USE.UNEQUIP:
			nextgun = GUN_USE.GUN1
	if $death.is_stopped():
		$death.start()
		$head/Camera/deathAnim.play("death")
		gunbob.stop(false)

func _on_death_timeout():
	if deathCount > 0:
		deathCount -= 1
	if deathCount <= 0:
		hasControl = false
		if eventManager != null:
			eventManager.play("endCutscene")
			eventManager.playerDeath = true

func _on_gunanim_animation_finished(anim_name):
	if anim_name == "bandaiduse":
		healqueue += 30
		heals -= 1
	if anim_name == "bandaiduseOnAlly":
		band.visible = false
		gunanim.stop(true)
		if aim.is_colliding():
			var healee = aim.get_collider()
			if healee.is_in_group("player"):
				var disto = global_transform.origin.distance_to(healee.global_transform.origin)
				if disto < 8:
					heals -= 1
					healee.healqueue += 30
	if anim_name == "nelevenunequip":
		neleven.visible = false
		if nextgun == GUN_USE.HEAL:
			gunanim.play("bandaidequip")
			gunstate = GUN_USE.HEAL
		if nextgun == GUN_USE.GUN2:
			gunanim.play("doublebequip")
			gunstate = GUN_USE.GUN2
		if nextgun == GUN_USE.GUN3:
			gunanim.play("lactionequip")
			gunstate = GUN_USE.GUN3
		if nextgun == GUN_USE.GUN4:
			gunanim.play("glauncherequip")
			gunstate = GUN_USE.GUN4
		if nextgun == GUN_USE.GUN5:
			gunanim.play("mac10equip")
			gunstate = GUN_USE.GUN5
	if anim_name == "doublebunequip":
		doubleb.visible = false
		if nextgun == GUN_USE.HEAL:
			gunanim.play("bandaidequip")
			gunstate = GUN_USE.HEAL
		if nextgun == GUN_USE.GUN1:
			gunanim.play("nelevenequip")
			gunstate = GUN_USE.GUN1
		if nextgun == GUN_USE.GUN3:
			gunanim.play("lactionequip")
			gunstate = GUN_USE.GUN3
		if nextgun == GUN_USE.GUN4:
			gunanim.play("glauncherequip")
			gunstate = GUN_USE.GUN4
		if nextgun == GUN_USE.GUN5:
			gunanim.play("mac10equip")
			gunstate = GUN_USE.GUN5
	if anim_name == "lactionunequip":
		laction.visible = false
		if nextgun == GUN_USE.HEAL:
			gunanim.play("bandaidequip")
			gunstate = GUN_USE.HEAL
		if nextgun == GUN_USE.GUN1:
			gunanim.play("nelevenequip")
			gunstate = GUN_USE.GUN1
		if nextgun == GUN_USE.GUN2:
			gunanim.play("doublebequip")
			gunstate = GUN_USE.GUN2
		if nextgun == GUN_USE.GUN4:
			gunanim.play("glauncherequip")
			gunstate = GUN_USE.GUN4
		if nextgun == GUN_USE.GUN5:
			gunanim.play("mac10equip")
			gunstate = GUN_USE.GUN5
	if anim_name == "glauncherunequip":
		glauncher.visible = false
		if nextgun == GUN_USE.HEAL:
			gunanim.play("bandaidequip")
			gunstate = GUN_USE.HEAL
		if nextgun == GUN_USE.GUN1:
			gunanim.play("nelevenequip")
			gunstate = GUN_USE.GUN1
		if nextgun == GUN_USE.GUN2:
			gunanim.play("doublebequip")
			gunstate = GUN_USE.GUN2
		if nextgun == GUN_USE.GUN3:
			gunanim.play("lactionequip")
			gunstate = GUN_USE.GUN3
		if nextgun == GUN_USE.GUN5:
			gunanim.play("mac10equip")
			gunstate = GUN_USE.GUN5
	if anim_name == "mac10unequip":
		mac10.visible = false
		if nextgun == GUN_USE.HEAL:
			gunanim.play("bandaidequip")
			gunstate = GUN_USE.HEAL
		if nextgun == GUN_USE.GUN1:
			gunanim.play("nelevenequip")
			gunstate = GUN_USE.GUN1
		if nextgun == GUN_USE.GUN2:
			gunanim.play("doublebequip")
			gunstate = GUN_USE.GUN2
		if nextgun == GUN_USE.GUN3:
			gunanim.play("lactionequip")
			gunstate = GUN_USE.GUN3
		if nextgun == GUN_USE.GUN4:
			gunanim.play("glauncherequip")
			gunstate = GUN_USE.GUN4
	if anim_name == "bandaidunequip":
		bandaid.visible = false
		if nextgun == GUN_USE.GUN1:
			gunanim.play("nelevenequip")
			gunstate = GUN_USE.GUN1
		if nextgun == GUN_USE.GUN2:
			gunanim.play("doublebequip")
			gunstate = GUN_USE.GUN2
		if nextgun == GUN_USE.GUN3:
			gunanim.play("lactionequip")
			gunstate = GUN_USE.GUN3
		if nextgun == GUN_USE.GUN4:
			gunanim.play("glauncherequip")
			gunstate = GUN_USE.GUN4
		if nextgun == GUN_USE.GUN5:
			gunanim.play("mac10equip")
			gunstate = GUN_USE.GUN5
