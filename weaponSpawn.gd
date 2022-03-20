extends Spatial

onready var player = get_tree().get_root().get_node("/root/Spatial/player")
export var weaponType = 1

var HUD = null

func _ready():
	HUD = get_tree().get_root().get_node("/root/Spatial/Control/hud")

	if weaponType == 0:
		$Sprite3D.visible = false
		$Sprite3D2.visible = true
	elif weaponType == 1:
		$Sprite3D.frame = 1
	elif weaponType == 2:
		$Sprite3D.frame = 4
	elif weaponType == 3:
		$Sprite3D.frame = 2
	elif weaponType == 4:
		$Sprite3D.frame = 3

func _on_Area_body_entered(body):
	if body.is_in_group("player"):
		if weaponType == 0 and !body.hasFlashlight:
			body.hasFlashlight = true
			body.ammoAudio.play()
			body.ammoPickedUp = true
			HUD._textPopup("press F to toggle the flashlight", 5)
			queue_free()
		elif weaponType == 1 and !body.hasDoubleb:
			body.hasDoubleb = true
			body.ammoAudio.play()
			body.ammoPickedUp = true
			queue_free()
		elif weaponType == 2 and !body.hasMac10:
			body.hasMac10 = true
			body.ammoAudio.play()
			body.ammoPickedUp = true
			queue_free()
		elif weaponType == 3 and !body.hasLaction:
			body.hasLaction = true
			body.ammoAudio.play()
			body.ammoPickedUp = true
			queue_free()
		elif weaponType == 4 and !body.hasGlauncher:
			body.hasGlauncher = true
			body.ammoAudio.play()
			body.ammoPickedUp = true
			queue_free()
