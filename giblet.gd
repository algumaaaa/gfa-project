extends Spatial

onready var sprite = $Sprite3D

func _ready():
	var r = floor(rand_range(1, 3))
	if r == 1:
		sprite.frame = 3
	if r == 2:
		sprite.frame = 9
	if r == 3:
		sprite.frame = 10

func _on_Timer_timeout():
	sprite.scale -= Vector3(0.1, 0.1, 0.1)
	sprite.offset.y -= 50
	if sprite.scale <= Vector3(0, 0, 0):
		queue_free()
