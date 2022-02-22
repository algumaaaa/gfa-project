extends AnimationPlayer

var startCutscene = false
var churchStarted = false
var endCutscene = false

func _on_churchEvent_body_entered(body):
	if body.is_in_group("player") and !churchStarted:
		play("churchEvent")
		churchStarted = true

func _on_street_body_entered(body):
	if body.is_in_group("player") and !startCutscene:
		play("startCutscene")
		startCutscene = true

func _on_doubleDoor_body_entered(body):
	if body.is_in_group("player") and !endCutscene:
		play("endCutscene")
		endCutscene = true
		yield(self, "animation_finished")
		get_tree().change_scene("res://menu.tscn")
