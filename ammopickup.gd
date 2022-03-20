extends Spatial

onready var GLOBAL = get_node("/root/GLOBAL/")
export var ammotype = 0
export var isOnExpert = true
onready var sprite = $Sprite3D
var ammoplus = 0

func _ready():
	sprite.frame = ammotype
	if !isOnExpert:
		if GLOBAL.d == 0.5:
			queue_free()

func _on_Area_body_entered(body):
	if body.is_in_group("player"):
		_manage_ammo()
		if ammotype == 0:
			body.nelevenammo += 30 + ammoplus
			body.mac10ammo += 30 + ammoplus
		if ammotype == 1:
			body.doublebammo += 20 + floor((ammoplus * 0.5))
		if ammotype == 2:
			body.glauncherammo += 4 + floor((ammoplus * 0.1))
		if ammotype == 3:
			body.lactionammo += 7 + floor((ammoplus * 0.3))
		body.ammoAudio.play()
		body.ammoPickedUp = true
		queue_free()
	pass 

func _on_door_body_entered(body):
	if body.is_in_group("player"):
		_manage_ammo()

func _manage_ammo():
	var p = self.get_parent()
	for c in p.get_children():
		if c == null:
			return
		if GLOBAL.r > 150:
			c.ammoplus = 25
		if GLOBAL.r >= 101 and GLOBAL.r <= 150:
			c.ammoplus = 15
		if GLOBAL.r >= 34 and GLOBAL.r <= 100:
			c.ammoplus = 5
		if GLOBAL.r <= 33:
			c.ammoplus = 0
