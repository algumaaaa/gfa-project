extends Spatial

export var ammotype = 0
onready var sprite = $Sprite3D

func _ready():
	sprite.frame = ammotype
	pass 

func _on_Area_body_entered(body):
	if body.is_in_group("player"):
		if ammotype == 0:
			body.nelevenammo += 20
			body.mac10ammo += 30
		if ammotype == 1:
			body.doublebammo += 10
		if ammotype == 2:
			body.glauncherammo += 4
		if ammotype == 3:
			body.lactionammo += 7
		queue_free()
	pass 
