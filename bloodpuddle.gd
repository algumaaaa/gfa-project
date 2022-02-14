extends Spatial

var onfloor = false
var bloodSounds = preload("res://Audio/Gore/Drop_Blood_02.wav")

onready var bloodPlayer = $AudioStreamPlayer3D
onready var sprite3d = $Sprite3D
onready var animplay = $AnimationPlayer

func _ready():
	randomize()

	if onfloor:
		bloodPlayer.stream = bloodSounds
		var rand = rand_range(0, 1)
		if rand > 0.5:
			bloodPlayer.play()
		sprite3d.frame_coords = Vector2(5, 0)
	else:
		sprite3d.frame_coords = Vector2(4, 0)
		animplay.play("drip")
	pass

func _on_Timer_timeout():
	queue_free()
