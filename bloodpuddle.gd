extends Spatial

var onfloor = false

onready var sprite3d = $Sprite3D
onready var animplay = $AnimationPlayer

func _ready():
	if onfloor:
		sprite3d.frame_coords = Vector2(5, 0)
	else:
		sprite3d.frame_coords = Vector2(4, 0)
		animplay.play("drip")
	pass

func _on_Timer_timeout():
	queue_free()
