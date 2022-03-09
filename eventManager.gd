extends AnimationPlayer

var startCutscene = false
var churchStarted = false
var endCutscene = false
var playerDeath = false

onready var player = get_tree().get_root().get_node("/root/Spatial/player/")

func _ready():
	player.eventManager = self

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
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().change_scene("res://menu.tscn")

func _process(delta):
	if playerDeath and !self.is_playing():
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().change_scene("res://menu.tscn")

