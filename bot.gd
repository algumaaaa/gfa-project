extends KinematicBody

onready var playerCamera = get_tree().get_root().get_node("/root/Spatial/player/head/Camera")

onready var maleSprite = $compositeSprites/maleSprite
onready var nelevenSprite = $compositeSprites/nelevenSprite
onready var mac10Sprite = $compositeSprites/mac10Sprite
onready var lactionSprite = $compositeSprites/lactionSprite
onready var glauncherSprite = $compositeSprites/glauncherSprite
onready var bandageSprite = $compositeSprites/bandageSprite

export var animframe = 0

var slowed = false
var damagequeue = 0

func _physics_process(delta):
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
	mac10Sprite.frame_coords = Vector2(animframe, animrow)
	lactionSprite.frame_coords = Vector2(animframe, animrow)
	glauncherSprite.frame_coords = Vector2(animframe, animrow)
	bandageSprite.frame_coords = Vector2(animframe, animrow)

	
