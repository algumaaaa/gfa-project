extends Sprite3D

var mouse_mov
var sway_threshold = 10
var sway_lerp = 1
export var shellsrelease = false

func _ready():
	shellsrelease = false
	pass 

func _input(event):
	if event is InputEventMouseMotion:
		mouse_mov = -event.relative.x

func _process(delta):
	if mouse_mov != null:
		if mouse_mov > sway_threshold:
			offset.x -= mouse_mov * delta
		if mouse_mov < -sway_threshold:
			offset.x -= mouse_mov * delta
		if offset.x > 0:
			offset.x -= sway_lerp + (offset.x * delta)
		if offset.x < 0:
			offset.x += sway_lerp + (offset.x * delta * -1)