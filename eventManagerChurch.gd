extends AnimationPlayer

var frontLeftRoom = false
var backLeftRoom = false
var backRightRoom = false
var passage = false
var altar = false
var westWingKey = false
var passageKey = false
var altarKey = false

var playerDeath = false
var endCutscene = false

var HUD = null

onready var player = get_tree().get_root().get_node("/root/Spatial/player/")


func _ready():
	HUD = get_tree().get_root().get_node("/root/Spatial/Control/hud")
	player.eventManager = self
	play("startCutscene")


func _on_doubleDoor_body_entered(body, extra_arg_0):
	if !body.is_in_group("player"):
		return
	if westWingKey == false and extra_arg_0 == 0:
		HUD._textPopup("locked", 5)
	if westWingKey == true and extra_arg_0 == 0 and backLeftRoom == false:
		play("openBackLeftDoor")
		backLeftRoom = true
	if frontLeftRoom == false and extra_arg_0 == 1:
		HUD._textPopup("does not open from this side", 5)
	if passageKey == false and extra_arg_0 == 2:
		HUD._textPopup("locked", 5)
	if passageKey == true and extra_arg_0 == 2 and passage == false:
		play("openPassage")
		passage = true
	if backRightRoom == false and extra_arg_0 == 3:
		HUD._textPopup("does not open from this side", 5)
	if extra_arg_0 == 4:
		if frontLeftRoom == false:
			play("openFrontLeftDoor")
			frontLeftRoom = true
	if extra_arg_0 == 5:
		if backRightRoom == false:
			play("openBackRightRoom")
			backRightRoom = true
	if altarKey == true and extra_arg_0 == 6 and altar == false:
		play("openAltar")
		altar = true


func _on_street_body_entered(body):
	body.hasDoubleb = true


func _process(delta):
	if playerDeath and !self.is_playing():
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().change_scene("res://menu.tscn")


func _on_doubleDoor_body_entered_end(body):
	if body.is_in_group("player") and !endCutscene:
		play("endCutscene")
		endCutscene = true
		yield(self, "animation_finished")
		SAVE.saveGame(3)
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().change_scene("res://e1m3.tscn")
