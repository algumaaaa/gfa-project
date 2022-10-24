extends AnimationPlayer

var playerDeath = false
var endCutscene = false

onready var player = get_tree().get_root().get_node("/root/Spatial/player/")


func _ready():
	player.eventManager = self
	play("startCutscene")


func _on_street_body_entered(body):
	if body.is_in_group("player"):
		body.hasFlashlight = true
		body.hasDoubleb = true
		body.hasMac10 = true
		body.hasLaction = true


func _process(delta):
	if playerDeath and !self.is_playing():
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().change_scene("res://menu.tscn")


func _on_street_body_entered_end(body):
	if body.is_in_group("player") and !endCutscene:
		play("endCutscene")
		endCutscene = true
		yield(self, "animation_finished")
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().change_scene("res://menu.tscn")
