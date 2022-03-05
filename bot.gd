extends KinematicBody

onready var playerCamera = get_tree().get_root().get_node("/root/Spatial/player/head/Camera")

onready var maleSprite = $compositeSprites/maleSprite
onready var nelevenSprite = $compositeSprites/nelevenSprite
onready var doublebSprite = $compositeSprites/doublebSprite
onready var mac10Sprite = $compositeSprites/mac10Sprite
onready var lactionSprite = $compositeSprites/lactionSprite
onready var glauncherSprite = $compositeSprites/glauncherSprite
onready var bandageSprite = $compositeSprites/bandageSprite

export var animframe = 0
onready var animSprite = $animSprite

var aiState = AI.IDLE
var weaponState = WEAPON.NELEVEN
var shortTarget = null

var slowed = false
var damagequeue = 0

enum AI{
	IDLE,
	PATHING,
	ATTACK,
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

func _physics_process(delta):

	if Input.is_action_just_pressed("debug0"):
		aiState = AI.DOWNED
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
			$compositeSprites/maleSprite.visible = true
			$compositeSprites/nelevenSprite.visible = true

		WEAPON.DOUBLEB:
			var cc = $compositeSprites.get_children()
			for w in cc:
				w.visible = false
			$compositeSprites/maleSprite.visible = true
			$compositeSprites/doublebSprite.visible = true

		WEAPON.MAC10:
			var cc = $compositeSprites.get_children()
			for w in cc:
				w.visible = false
			$compositeSprites/maleSprite.visible = true
			$compositeSprites/mac10Sprite.visible = true

		WEAPON.LACTION:
			var cc = $compositeSprites.get_children()
			for w in cc:
				w.visible = false
			$compositeSprites/maleSprite.visible = true
			$compositeSprites/lactionSprite.visible = true

		WEAPON.GLAUNCHER:
			var cc = $compositeSprites.get_children()
			for w in cc:
				w.visible = false
			$compositeSprites/maleSprite.visible = true
			$compositeSprites/glauncherSprite.visible = true

		WEAPON.BANDAGE:
			var cc = $compositeSprites.get_children()
			for w in cc:
				w.visible = false
			$compositeSprites/maleSprite.visible = true
			$compositeSprites/bandageSprite.visible = true

	match aiState:

		AI.IDLE:
			animSprite.stop()
			if weaponState == WEAPON.BANDAGE or weaponState == WEAPON.NELEVEN or weaponState == WEAPON.MAC10:
				animframe = 0
			else:
				animframe = 7
			_findEnemies()

		AI.PATHING:
			if weaponState == WEAPON.BANDAGE or weaponState == WEAPON.NELEVEN or weaponState == WEAPON.MAC10:
				if !animSprite.is_playing():
					animSprite.play("runPistol")
			else:
				if !animSprite.is_playing():
					animSprite.play("runRifle")

		AI.ATTACK:
			animSprite.stop()
			if weaponState == WEAPON.BANDAGE or WEAPON.NELEVEN or WEAPON.MAC10:
				animframe = 0
			else:
				animframe = 7

		AI.DOWNED:
			animSprite.stop()
			animframe = 14

func _findEnemies():
	var targets = get_tree().get_nodes_in_group("alertEnemies")
	for t in targets:
		var disto = self.global_transform.origin.distance_to(t.global_transform.origin)
		if shortTarget == null:
			shortTarget = t
		elif disto < shortTarget.global_transform.origin.distance_to(t.global_transform.origin):
			shortTarget = t
	if shortTarget == null:
		return
	if self.global_transform.origin.distance_to(shortTarget.global_transform.origin) < 30:
		$aim.look_at(shortTarget.global_transform.origin, Vector3.UP)
