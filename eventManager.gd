extends AnimationPlayer

var started = false

func _on_churchEvent_body_entered(body):
	if body.is_in_group("player") and !started:
		play("churchEvent")
		started = true
