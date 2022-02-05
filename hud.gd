extends Control

onready var GLOBAL = get_node("/root/GLOBAL/")
onready var player = get_tree().get_root().get_node("/root/Spatial/player")
#onready var spawner = get_tree().get_root().get_node("/root/Spatial/Navigation/spawner")

onready var ammo = $ammo
onready var fps = $fps
onready var health = $health
onready var dmgs = $damagesplash
onready var heals = $healedsplash
onready var animplayer = $AnimationPlayer

func _process(delta):
	if player.gunstate == player.GUN_USE.GUN1:
		ammo.text = "pistol: " + str(player.nelevenammo)
	if player.gunstate == player.GUN_USE.GUN2:
		ammo.text = "sawed off: " + str(player.doublebammo)
	if player.gunstate == player.GUN_USE.GUN3:
		ammo.text = "lever action: " + str(player.lactionammo)
	if player.gunstate == player.GUN_USE.GUN4:
		ammo.text = "grenades: " + str(player.glauncherammo)
	if player.gunstate == player.GUN_USE.GUN5:
		ammo.text = "mac10: " + str(player.mac10ammo)
	if player.gunstate == player.GUN_USE.HEAL:
		ammo.text = "heals: " + str(player.heals)

	fps.text = "fps: " + str(Engine.get_frames_per_second()) + " r: " + str(GLOBAL.r)  + " a: " + str(GLOBAL.a) + " m: " + str(GLOBAL.m) + " tick: " + str(GLOBAL.tick) 
	health.text = "health: " + str(player.health)

	if player.damagequeue > 0 and !animplayer.is_playing():
		if player.damagequeue < 20:
			animplayer.play("dmg")
		else: 
			animplayer.play("dmgheavy")
	if player.healqueue > 0 and !animplayer.is_playing():
		animplayer.play("heal")
