extends Sprite3D

onready var doubleb = get_tree().get_root().get_node("/root/Spatial/player/head/Camera/doubleb")
onready var neleven = get_tree().get_root().get_node("/root/Spatial/player/head/Camera/neleven")
onready var laction = get_tree().get_root().get_node("/root/Spatial/player/head/Camera/laction")
onready var mac10 = get_tree().get_root().get_node("/root/Spatial/player/head/Camera/mac10")
onready var player = get_tree().get_root().get_node("/root/Spatial/player")
onready var playshoot = $muzzleshoot

func _process(delta):
	if player == null:
		return
	if player.gunstate == player.GUN_USE.GUN1:
		self.offset.x = neleven.offset.x + 12
		self.offset.y = 35
		self.pixel_size = 0.01
	if player.gunstate == player.GUN_USE.GUN2:
		self.offset.x = doubleb.offset.x
		self.offset.y = 0
		self.pixel_size = 0.015
	if player.gunstate == player.GUN_USE.GUN3:
		self.offset.x = laction.offset.x - 17
		self.offset.y = 30
		self.pixel_size = 0.010
	if player.gunstate == player.GUN_USE.GUN5:
		self.offset.x = mac10.offset.x + 20
		self.offset.y = 25
		self.pixel_size = 0.010
	pass

func _on_gunanim_animation_started(anim_name):
	if anim_name == "doublebshoot":
		playshoot.play("shoot")
	elif anim_name == "doublebreload":
		playshoot.play("shoot")
	elif anim_name == "nelevenshoot":
		playshoot.play("shoot")
	elif anim_name == "lactionshoot":
		playshoot.play("shoot")
	elif anim_name == "mac10shoot":
		playshoot.play("smgshoot")
	pass 
