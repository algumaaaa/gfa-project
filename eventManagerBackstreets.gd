extends AnimationPlayer

var key = [false, false, false, false, false]
var used = [false, false, false, false, false, false, false]
var trap = false
var HUD = null

func _ready():
	HUD = get_tree().get_root().get_node("/root/Spatial/Control/hud")

func _on_street_body_entered(body, extra_arg_0):
	if body.is_in_group("player"):
		if extra_arg_0 == 1:
			body.hasDoubleb = true
			body.hasMac10 = true
			body.hasFlashlight = true
		if extra_arg_0 == 0 and trap == false:
			play("trap")
			trap = true

func _on_door_body_entered(body, extra_arg_0):
	if body.is_in_group("player"):
		if extra_arg_0 == 0 and used[0] == false:
			if key[0]:
				play("openDoor1")
				used[0] = true
			else:
				HUD._textPopup("locked", 5)
		if extra_arg_0 == 1 and used[1] == false:
			if key[1]:
				play("openDoor2")
				used[1] = true
			else:
				HUD._textPopup("locked", 5)
		if extra_arg_0 == 2 and used[2] == false:
				HUD._textPopup("does not open from this side", 5)
		if extra_arg_0 == 3 and used[3] == false:
			if key[2]:
				play("openDoor4")
				used[3] = true
			else:
				HUD._textPopup("locked", 5)
		if extra_arg_0 == 4 and used[4] == false:
			if key[3]:
				play("openDoor5")
				used[4] = true
			else:
				HUD._textPopup("locked", 5)
		if extra_arg_0 == 5 and used[5] == false:
			if key[4]:
				play("openDoor6")
				used[5]
			else:
				HUD._textPopup("locked", 5)
		if extra_arg_0 == 6 and used[6] == false:
			play("openDoor3")
			used[6] = true
			used[2] = true
			pass

func _on_rainSound_finished():
	$rainSound.play()
