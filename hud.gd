extends Control

onready var GLOBAL = get_node("/root/GLOBAL/")
onready var player = get_tree().get_root().get_node("/root/Spatial/player")
#onready var spawner = get_tree().get_root().get_node("/root/Spatial/Navigation/spawner")

onready var health = $VBoxContainer2/health
onready var ammo = $VBoxContainer2/ammo
onready var bands = $VBoxContainer2/bands
onready var fps = $fps
onready var dmgs = $damagesplash
onready var heals = $healedsplash
onready var animplayer = $AnimationPlayer
onready var textrect1 = $VBoxContainer/TextureRect
onready var textrect2 = $VBoxContainer/TextureRect2
onready var textrect3 = $VBoxContainer/TextureRect3
onready var textrect4 = $VBoxContainer/TextureRect4
onready var textrect5 = $VBoxContainer/TextureRect5

func _draw():
	if player.gunstate == player.GUN_USE.GUN1:
		textrect1.BLEND_MODE_SUB

func _process(delta):
	if player.gunstate == player.GUN_USE.GUN1:
		ammo.text = "pistol: " + str(player.nelevenammo)
		textrect1.modulate = Color(1, 0, 0, 1)
	else:
		textrect1.modulate = Color(1, 1, 1, 1)

	if player.gunstate == player.GUN_USE.GUN2:
		ammo.text = "sawed off: " + str(player.doublebammo)
		textrect2.modulate = Color(1, 0, 0, 1)
	else:
		textrect2.modulate = Color(1, 1, 1, 1)

	if player.gunstate == player.GUN_USE.GUN3:
		ammo.text = "lever action: " + str(player.lactionammo)
		textrect4.modulate = Color(1, 0, 0, 1)
	else:
		textrect4.modulate = Color(1, 1, 1, 1)

	if player.gunstate == player.GUN_USE.GUN4:
		ammo.text = "grenades: " + str(player.glauncherammo)
		textrect5.modulate = Color(1, 0, 0, 1)
	else:
		textrect5.modulate = Color(1, 1, 1, 1)

	if player.gunstate == player.GUN_USE.GUN5:
		ammo.text = "mac10: " + str(player.mac10ammo)
		textrect3.modulate = Color(1, 0, 0, 1)
	else:
		textrect3.modulate = Color(1, 1, 1, 1)

	if player.gunstate == player.GUN_USE.HEAL:
		bands.modulate = Color(1, 0, 0, 1)
	else:
		bands.modulate = Color(1, 1, 1, 1)

	bands.text = "bandages " + str(player.heals)
	fps.text = "fps: " + str(Engine.get_frames_per_second())
#	# + " r: " + str(GLOBAL.r)  + " a: " + str(GLOBAL.a) + " m: " + str(GLOBAL.m) + " tick: " + str(GLOBAL.tick) 
	health.text = "health: " + str(player.health)

	if player.damagequeue > 0 and !animplayer.is_playing():
		if player.damagequeue < 20:
			animplayer.play("dmg")
		else: 
			animplayer.play("dmgheavy")
	if player.healqueue > 0 and !animplayer.is_playing():
		animplayer.play("heal")
