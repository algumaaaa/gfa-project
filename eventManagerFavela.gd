extends AnimationPlayer


func _ready():
	pass


func _on_street_body_entered(body):
	if body.is_in_group("player"):
		body.hasFlashlight = true
		body.hasDoubleb = true
		body.hasMac10 = true
		body.hasLaction = true
