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

func _ready():
	if !GLOBAL.bot1Enabled:
		$VBoxContainer3/botName1.visible = false
		$VBoxContainer3/bot1.visible = false
		$VBoxContainer3/botHealth1.visible = false
		$VBoxContainer3/botAmmo1.visible = false
		$VBoxContainer3/HSeparator.visible = false
		$VBoxContainer4/deathTimer.visible = false
	if !GLOBAL.bot2Enabled:
		$VBoxContainer3/botName2.visible = false
		$VBoxContainer3/bot2.visible = false
		$VBoxContainer3/botHealth2.visible = false
		$VBoxContainer3/botAmmo2.visible = false
		$VBoxContainer3/HSeparator2.visible = false
		$VBoxContainer4/deathTimer2.visible = false
	if !GLOBAL.bot3Enabled:
		$VBoxContainer3/botName3.visible = false
		$VBoxContainer3/bot3.visible = false
		$VBoxContainer3/botHealth3.visible = false
		$VBoxContainer3/botAmmo3.visible = false
		$VBoxContainer4/deathTimer3.visible = false

	if !GLOBAL.bot1Enabled and !GLOBAL.bot2Enabled and !GLOBAL.bot3Enabled:
		$Panel4.visible = false

func _draw():
	if player.gunstate == player.GUN_USE.GUN1:
		textrect1.BLEND_MODE_SUB

func _process(delta):
	if player.gunstate == player.GUN_USE.GUN1:
		ammo.text = "pistol: " + str(player.nelevenammo)
		textrect1.modulate = Color(1, 0, 0, 1)
	else:
		textrect1.modulate = Color(1, 1, 1, 1)

	if player.hasDoubleb:
		if player.gunstate == player.GUN_USE.GUN2:
			ammo.text = "sawed off: " + str(player.doublebammo)
			textrect2.modulate = Color(1, 0, 0, 1)
		else:
			textrect2.modulate = Color(1, 1, 1, 1)
	else:
		textrect2.modulate = Color(0, 0, 0, 1)

	if player.hasLaction:
		if player.gunstate == player.GUN_USE.GUN3:
			ammo.text = "lever action: " + str(player.lactionammo)
			textrect4.modulate = Color(1, 0, 0, 1)
		else:
			textrect4.modulate = Color(1, 1, 1, 1)
	else:
		textrect4.modulate = Color(0, 0, 0, 1)

	if player.hasGlauncher:
		if player.gunstate == player.GUN_USE.GUN4:
			ammo.text = "grenades: " + str(player.glauncherammo)
			textrect5.modulate = Color(1, 0, 0, 1)
		else:
			textrect5.modulate = Color(1, 1, 1, 1)
	else:
		textrect5.modulate = Color(0, 0, 0, 1)

	if player.hasMac10:
		if player.gunstate == player.GUN_USE.GUN5:
			ammo.text = "mac10: " + str(player.mac10ammo)
			textrect3.modulate = Color(1, 0, 0, 1)
		else:
			textrect3.modulate = Color(1, 1, 1, 1)
	else:
		textrect3.modulate = Color(0, 0, 0, 1)

	if player.gunstate == player.GUN_USE.HEAL:
		bands.modulate = Color(1, 0, 0, 1)
	else:
		bands.modulate = Color(1, 1, 1, 1)

	bands.text = "bandages " + str(player.heals)
	#fps.text = "fps: " + str(Engine.get_frames_per_second()) + " r: " + str(GLOBAL.r)  + " a: " + str(GLOBAL.a) + " m: " + str(GLOBAL.m) + " tick: " + str(GLOBAL.tick) 
	health.text = "health: " + str(player.health)

	if player.damagequeue > 0 and !animplayer.is_playing():
		if player.damagequeue < 20:
			animplayer.play("dmg")
		else: 
			animplayer.play("dmgheavy")
	if player.healqueue > 0 and !animplayer.is_playing():
		animplayer.play("heal")
	if player.slowed == true and !animplayer.is_playing():
		$slowAnim.play("slow")

	if player.bloody == 3:
		$bloodyScreenAnim.play("bloody1")
	if player.bloody == 6:
		$bloodyScreenAnim.play("bloody2")
	if player.bloody == 8:
		$bloodyScreenAnim.play("bloody3")
	if player.bloody >= 12:
		$bloodyScreenAnim.play("bloody4")

	if player.ammoPickedUp and !animplayer.is_playing():
		animplayer.play("ammo")

	if GLOBAL.bot1Enabled:
		$VBoxContainer3/botName1.text = GLOBAL.bot1Name
		$VBoxContainer3/bot1.modulate = GLOBAL.bot1Color
		$VBoxContainer3/botHealth1.text = "health: " + str(GLOBAL.bot1Health)
		$VBoxContainer3/botAmmo1.text = "ammo: " + str(GLOBAL.bot1Ammo)
		if GLOBAL.bot1Deathcounter != 30:
			$VBoxContainer4/deathTimer.visible = true
			$VBoxContainer4/deathTimer.text = str(GLOBAL.bot1Deathcounter)
		else:
			$VBoxContainer4/deathTimer.visible = false
	if GLOBAL.bot2Enabled:
		$VBoxContainer3/botName2.text = GLOBAL.bot2Name
		$VBoxContainer3/bot2.modulate = GLOBAL.bot2Color
		$VBoxContainer3/botHealth2.text = "health: " + str(GLOBAL.bot2Health)
		$VBoxContainer3/botAmmo2.text = "ammo: " + str(GLOBAL.bot2Ammo)
		if GLOBAL.bot2Deathcounter != 30:
			$VBoxContainer4/deathTimer2.visible = true
			$VBoxContainer4/deathTimer2.text = str(GLOBAL.bot2Deathcounter)
		else:
			$VBoxContainer4/deathTimer2.visible = false
	if GLOBAL.bot3Enabled:
		$VBoxContainer3/botName3.text = GLOBAL.bot3Name
		$VBoxContainer3/bot3.modulate = GLOBAL.bot3Color
		$VBoxContainer3/botHealth3.text = "health: " + str(GLOBAL.bot3Health)
		$VBoxContainer3/botAmmo3.text = "ammo: " + str(GLOBAL.bot3Ammo)
		if GLOBAL.bot3Deathcounter != 30:
			$VBoxContainer4/deathTimer3.visible = true
			$VBoxContainer4/deathTimer3.text = str(GLOBAL.bot3Deathcounter)
		else:
			$VBoxContainer4/deathTimer3.visible = false

func _on_bloodyScreenAnim_animation_finished(anim_name):
	player.bloody = 0

func _textPopup(text, time):
	$textPopup.visible = true
	$textPopup.text = text
	var textTimer = Timer.new()
	textTimer.wait_time = time
	textTimer.one_shot = true
	textTimer.connect("timeout", self, "_on_textTimer_timeout")
	add_child(textTimer)
	textTimer.start()

func _on_textTimer_timeout():
	$textPopup.visible = false
